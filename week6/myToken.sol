pragma solidity ^0.4.24;
import "./ERC20.sol";

contract MyCoin is TokenERC20 {
  uint swapRate = 100;
  uint limit = 1000e18;

  constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

  function saleToken() public payable {
    require(msg.value>0);
    require(totalSupply<limit);
    uint toSale;
    uint toReturn;
    // 発行上限に達している時は残り全部発行してあげる.
    if(msg.value*100>(limit-totalSupply)){
      toSale = limit-totalSupply; // 発行上限-発行済みトークン
      toReturn = msg.value - toSale/100;
    }
    else{ // 発行上限に達していない場合はその分だけ発行してあげる.
      toSale = msg.value*100;
      toReturn = 0;
    }
    balances[msg.sender] = balances[msg.sender] + toSale;
  }
}
