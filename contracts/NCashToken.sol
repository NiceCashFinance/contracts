pragma solidity 0.6.6;

import "./token/ERC20/ERC20.sol";
import "./token/ERC20/ERC20Burnable.sol";
import "./math/SafeMath.sol";

contract NCashToken is ERC20, ERC20Burnable {

    using SafeMath for uint256;
    uint256 public start;

    mapping (address => uint256) public lockedBalance;

    constructor() ERC20("NiceCash Token", "NCT") public {
        _mint(msg.sender, 100000000 * (10 ** uint(decimals())));
        start = now;

    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(lockedBalance[from] == 0 || amount <= vestedAmount(from));
    }

    function transferWithVesting(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        lockedBalance[recipient] = lockedBalance[recipient].add(amount);
        return true;
    }

    /**
   * @dev Calculates the amount that has already vested.
   */
    function vestedAmount(address from) public view returns (uint256) {
        uint256 balance = balanceOf(address(from));
        
        if (now >= start + 360 days) {
            return balance;
        } else if (now >= start + 330 days) {
            return balance.sub(lockedBalance[from].div(12));
        } else if (now >= start + 300 days) {
            return balance.sub(lockedBalance[from].div(12).mul(2));
        } else if (now >= start + 270 days) {
            return balance.sub(lockedBalance[from].div(12).mul(3));
        } else if (now >= start + 240 days) {
            return balance.sub(lockedBalance[from].div(12).mul(4));
        } else if (now >= start + 210 days) {
            return balance.sub(lockedBalance[from].div(12).mul(5));
        } else if (now >= start + 180 days) {
            return balance.sub(lockedBalance[from].div(12).mul(6));
        } else if (now >= start + 150 days) {
            return balance.sub(lockedBalance[from].div(12).mul(7));
        } else if (now >= start + 120 days) {
            return balance.sub(lockedBalance[from].div(12).mul(8));
        } else if (now >= start + 90 days) {
            return balance.sub(lockedBalance[from].div(12).mul(9));
        } else if (now >= start + 60 days) {
            return balance.sub(lockedBalance[from].div(12).mul(10));
        } else if (now >= start + 30 days) {
            return balance.sub(lockedBalance[from].div(12).mul(11));
        } else {
            return balance.sub(lockedBalance[from]);
        }
    }
}