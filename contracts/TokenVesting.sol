pragma solidity 0.6.6;

import "./token/ERC20/ERC20.sol";
import "./token/ERC20/SafeERC20.sol";
import "./access/Ownable.sol";
import "./math/SafeMath.sol";


/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually
 * like a typical vesting scheme, with a cliff and vesting period. After
 * deployment, the owner must transfer ownership of some ERC-20 tokens to the
 * address of this deployed TokenVesting contract. Revocable by the
 * owner.
 */
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  event Withdrawal(uint256 amount);
  event Revoked();


  ERC20 public token; // ERC20 token
  address public beneficiary; // beneficiary address, tokens tokens to be sent there upon release
  uint256 public start; // unix timestamp;

  uint256 public withdrawnAmount;
  bool public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token _token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration,  afterwhich all
   * of the balance will have vested... Vested tokens are only withdrawable after _start + _cliff.
   * @param _token address of the ERC20 token contract whose tokens will be vested by this contract
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _start unix timestamp of when the contract should start
   */
  constructor (
    ERC20 _token,
    address _beneficiary,
    uint256 _start
  )
    public
  {
    require(_beneficiary != address(0));

    token = _token; //ERC20(_token);
    beneficiary = _beneficiary;
    start = _start;
  }

  /**
   * @notice Transfers vested tokens to beneficiary. Only callable by beneficiary
   */
  function withdraw() public {
    require(msg.sender == beneficiary);

    uint256 withdrawable = withdrawableAmount();
    require(withdrawable > 0);

    withdrawnAmount = withdrawnAmount.add(withdrawable);

    token.safeTransfer(beneficiary, withdrawable);

    emit Withdrawal(withdrawable);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain with the contract, the rest are returned to the owner.
   */
  function revoke() public onlyOwner {
    require(!revoked);

    uint256 balance = token.balanceOf(address(this));
    uint256 withdrawable = withdrawableAmount();
    uint256 refund = balance.sub(withdrawable);

    revoked = true;

    token.safeTransfer(owner(), refund);

    emit Revoked();
  }
  
  function setBeneficiary(address _beneficiary) external onlyOwner {
      beneficiary = _beneficiary;
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been withdrawn yet.
   */
  function withdrawableAmount() public view returns (uint256) {
    return vestedAmount().sub(withdrawnAmount);
  }

  /**
   * @dev Calculates the amount that has already vested.
   */
  function vestedAmount() public view returns (uint256) {
    uint256 balance = token.balanceOf(address(this));
    uint256 totalVesting = balance.add(withdrawnAmount);

    if (now >= start + 12 days) {
        return totalVesting;
    } else if (now >= start + 11 days) {
        return totalVesting.div(2);
    } else if (now >= start + 10 days) {
        return totalVesting.div(3);
    } else if (now >= start + 9 days) {
        return totalVesting.div(4);
    } else if (now >= start + 8 days) {
        return totalVesting.div(5);
    } else if (now >= start + 7 days) {
        return totalVesting.div(6);
    } else if (now >= start + 6 days) {
        return totalVesting.div(7);
    } else if (now >= start + 5 days) {
        return totalVesting.div(8);
    } else if (now >= start + 4 days) {
        return totalVesting.div(9);
    } else if (now >= start + 3 days) {
        return totalVesting.div(10);
    } else if (now >= start + 2 days) {
        return totalVesting.div(11);
    } else if (now >= start + 1 days) {
        return totalVesting.div(12);
    } else {
        return 0;
    }
    
  }
}
