pragma solidity 0.6.6;

import "./token/ERC20/ERC20.sol";
import "./token/ERC20/SafeERC20.sol";
import "./math/SafeMath.sol";
import "./access/Ownable.sol";
import "./utils/Pausable.sol";

struct VaultEntry {
    uint32 blocknumber;
    uint256 amountLocked;
    uint256 deposited;
    uint256 withdrawn;
}

contract NiceCashVault is Ownable, Pausable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public niceCashToken;
    uint256 public minimumAmountDeposited;//min amt of tokens to deposit
    uint256 public minimumAmountLocked;//min amt to be locked for gaining earnings
    uint256 public totalValueLocked;


    uint256[] public apyNom; //APY%
    uint256[] public apyDenom; //ethereum blocks per year multiplied by 100%;
    uint32[] public apyBlock;
    uint8 public apyIndex;

    mapping (address => VaultEntry) vaults;

    event Deposit(address who, uint256 amount);

    event Withdraw(address who, uint256 amount);

    constructor(address _niceCashTokenAddress) public {
        niceCashToken = IERC20(_niceCashTokenAddress);
        minimumAmountLocked = 10000 * (10 ** 18);
        minimumAmountDeposited = 1000 * (10 ** 18);
        apyNom.push(110);//110%
        apyDenom.push(225405000);//ethereum blocks per year multiplied by 100%;
        apyBlock.push(uint32(block.number));
        apyIndex=0;
    }

    function setMinimumAmountDeposited(uint256 amount) onlyOwner external {
        minimumAmountDeposited = amount;
    }

    function setMinimumAmountLocked(uint256 amount) onlyOwner external {
        minimumAmountLocked = amount;
    }

    function setApy(uint256 _apyNom, uint256 _apyDenom, uint32 _block) onlyOwner external {
        require (_apyNom > 0,'_apyNom is not correct');
        require (_apyDenom > 0,'_apyDenom is not correct');
        require (_block > apyBlock[apyIndex],'_block to be greater than previous recorded');
        apyNom.push(_apyNom);
        apyDenom.push(_apyDenom);
        apyBlock.push(_block);
        apyIndex = apyIndex+1;
    }

    function deposit(uint256 amount) external {
        require(!paused(), "Deposits are blocked when paused");
        require(amount >= minimumAmountDeposited, 'Amount should be greater than minimumAmountDeposited');
        niceCashToken.safeTransferFrom(msg.sender, address(this), amount);
        //recalculate earnings as of today, add to current balance;
        uint256 earnings=_calcEarnings(msg.sender, block.number);
        vaults[msg.sender].amountLocked = vaults[msg.sender].amountLocked.add(earnings).add(amount);
         //update totals
        totalValueLocked = totalValueLocked.add(earnings).add(amount);
        vaults[msg.sender].blocknumber = uint32(block.number);
        //record stat
        vaults[msg.sender].deposited = vaults[msg.sender].deposited.add(amount);

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        _withdraw(amount, msg.sender);
    }

    function withdrawTo(uint256 amount, address to) external {
        _withdraw(amount, to);
    }

    function pause() onlyOwner public {
        super._pause();
    }

    function unpause() onlyOwner public {
        super._unpause();
    }

    function getUserData(address user) public view returns (uint32, uint256, uint256, uint256){
        return (vaults[user].blocknumber, vaults[user].amountLocked, vaults[user].deposited, vaults[user].withdrawn);
    }

    function getCurrentAPY() public view returns (uint256) {
        return apyNom[apyIndex];
    }

    function _calcEarnings(address _user, uint _blockNumber) internal returns(uint256) {
        //no earnings if deposit is less then minimumAmountLocked
        if(vaults[_user].amountLocked < minimumAmountLocked)
            return 0;

        uint32 blocknumber=uint32(_blockNumber);
        int64 period = int64(blocknumber - vaults[_user].blocknumber);
        
        uint256 earnings;
        uint8 index=apyIndex;
        do{
            uint256 blocksAmt = blocknumber - max(vaults[_user].blocknumber,apyBlock[index]);
            earnings = earnings.add(blocksAmt.mul(vaults[_user].amountLocked).mul(apyNom[index]).div(apyDenom[index]));
            period = period - int64(blocksAmt);
            blocknumber = apyBlock[index];
            if(index == 0)
                break;
            else
                index = index - 1;
        } while(period > 0);
        return earnings;
    }

    function max(uint32 a, uint32 b) private pure returns (uint32) {
        return a > b ? a : b;
    }

    function _withdraw(uint256 amount, address to) internal {
       
        //recalculate earnings as of today, add to current balance;
        uint256 earnings=_calcEarnings(msg.sender, block.number);
        require(amount <= vaults[msg.sender].amountLocked.add(earnings),"Not enougn funds available");

        vaults[msg.sender].amountLocked = vaults[msg.sender].amountLocked.add(earnings).sub(amount);
        vaults[msg.sender].blocknumber = uint32(block.number);
        niceCashToken.safeTransfer(to, amount);
        //update totals
        totalValueLocked = totalValueLocked.add(earnings).sub(amount);
        //record stat
        vaults[msg.sender].withdrawn = vaults[msg.sender].withdrawn.add(amount);

        emit Withdraw(msg.sender, amount);
    }
}