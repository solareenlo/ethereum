pragma solidity ^0.5.2;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
// import "./SafeMath.sol";

contract RSPgo{
  using SafeMath for uint256;
  uint gameCount;
  uint constant betAmount = 1 ether; // 掛け金
  uint256 countStart;

  address payable player1;
  address payable player2;
  address lastWinner;
  address payable constant junkAddress = address(0); // 初期化用

  bytes32 constant junkByte = bytes32(0);
  bytes32 player1Hash;
  bytes32 player2Hash;

  uint player1Choice;
  uint player2Choice;

  event player1Enter(address player1);
  event player2Enter(address player2);
  event gameDone(uint gameCount, address player);
  event LogCanNotSetChoice(address player, uint256 number);

  // さぁ、闇のゲームを始めるぞ！
  function startGame(bytes32 player1hash) public payable {
    // 初めにplayer1がhashed Handを出す.
    require(player1Hash == junkByte); // player1Hashを初期化
    require(betAmount == msg.value); // 1Etherが必要

    player1Hash = player1hash;
    player1 = msg.sender;

    emit player1Enter(player1); // log内のeventに出力
  }

  // 闇のゲームに乗った！
  function challengeCame(bytes32 player2hash) public payable {
    // 2人が参加した時点で, 他の人が参加できないように締切る.
    require(player1Hash != junkByte); // player1Hashが既に登録されていることを確認
    require(player2Hash == junkByte); // player2Hashの初期化
    require(betAmount == msg.value); // 1Etherが必要
    player2Hash = player2hash;
    player2 = msg.sender;

    // この関数が実行されたら, １日以内にsubmitNumberを2人に実行してもらう.
    countStart = now; // unit block.timestamp(unixtime)のエイリアス[予約時間]
    emit player2Enter(player2);
  }

  // 勝者の決定
  function _finalize() private {
    require(player1Choice > 0 && player2Choice > 0);

    // じゃんけんなので順繰りにしたいので, +1ずつ確かめてる.
    if (player1Choice == player2Choice + 1) {
      player1.transfer(betAmount.mul(2)); // betAmountを2倍して, player1に送金してる
      _gameFinish(player1);
    } else if (player2Choice == player1Choice + 1) {
      player2.transfer(betAmount.mul(2));
      _gameFinish(player2);
    } else if (player2Choice == player1Choice + 2) {
      player1.transfer(betAmount.mul(2));
      _gameFinish(player1);
    } else if (player1Choice == player2Choice + 2) {
      player2.transfer(betAmount.mul(2));
      _gameFinish(player2);
    } else {
      player1.transfer(betAmount);
      player2.transfer(betAmount);
      _gameFinish(junkAddress);
    }
  }

  // (勝者決定後)初期化して, 次の試合に備える
  function _gameFinish(address _winner) private {
    emit gameDone(gameCount, _winner);
    gameCount++;

    player1 = junkAddress;
    player2 = junkAddress;
    lastWinner = _winner;

    player1Hash = junkByte;
    player2Hash = junkByte;

    player1Choice = 0;
    player2Choice = 0;
  }

  // 出す手の番号をhashする. (submitNumberで使用)
  function transferMyHand(uint256 _number) public pure returns (bytes32 hashed_number) {
    hashed_number = keccak256(abi.encode(_number));
  }

  // 出した手の番号を提出し, 初めに出した手のhashと一致するか確認.
  function submitNumber(uint256 number) public {
    bytes32 hexhash = transferMyHand(number);
    if(msg.sender==player1 && player1Hash==hexhash) {
      player1Choice = number % 3 + 1; // changed
    } else if (msg.sender==player2 && player2Hash==hexhash) {
      player2Choice = number % 3 + 1; // changed
    } else {
      emit LogCanNotSetChoice(msg.sender, number);
    }

    if (player1Choice>0 && player2Choice>0) {
      _finalize();
    }
  }

  // 提出期限過ぎた場合は, 審査員が来て強制終了する
  function submitTimeout(address delayer) public payable {
    require(delayer != junkAddress);
    require(now > countStart + 1 seconds); // 締切期限は5分後
    if (delayer == player1 && player1Choice == 0) {
      player2.transfer(betAmount.mul(19).div(10));
      msg.sender.transfer(betAmount.mul(1).div(10)); // 5%の手数料を製作者へ
      _gameFinish(player2);
    } else if (delayer == player2 && player2Choice == 0) {
      player1.transfer(betAmount.mul(19).div(10));
      msg.sender.transfer(betAmount.mul(1).div(10)); // 5%の手数料を製作者へ
      _gameFinish(player1);
    }
  }
}
