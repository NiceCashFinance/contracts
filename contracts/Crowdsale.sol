pragma solidity 0.6.6;

import "./token/ERC20/IERC20.sol";
import "./token/ERC20/SafeERC20.sol";
import "./token/ERC20/ERC20.sol";
import "./math/SafeMath.sol";

contract Crowdsale {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;
    address payable public wallet;
    uint256 public startRate;
    uint256 public endRate;
    uint256 public tokenDesired;
    uint256 public tokensRaised;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    constructor(address _token, address payable _wallet, uint256 _startRate, uint256 _endRate, uint256 _tokenDesired) public {
        token = IERC20(_token);
        wallet = _wallet;
        startRate = _startRate;
        endRate = _endRate;
        tokenDesired = _tokenDesired;
        tokensRaised = 0;
    }

    receive() external payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(uint256(10) ** ERC20(address(token)).decimals()).div(getRate());
        tokensRaised = tokensRaised.add(tokens);
        token.safeTransfer(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        forwardFunds();
    }

    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    function getRate() public view returns (uint256) {
        return endRate.sub(tokenDesired.sub(tokensRaised).mul(endRate.sub(startRate)).div(tokenDesired));
    }

}
