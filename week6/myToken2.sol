pragma solidity ^0.5.2;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

contract ExampleToken is ERC20, ERC20Detailed {
    uint private INITIAL_SUPPLY = 10000e18;
    constructor () public
    ERC20Detailed("ExampleToken", "EGT", 18) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
