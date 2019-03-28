pragma solidity ^0.4.25;

import "./SafeMath.sol";

contract ERC721WithDex {
    using SafeMath for uint;

    uint tokenCounter = 0;
    uint onBoardConter = 0;

    mapping(address => uint[]) private ownedTokens;
    mapping(uint => uint) private ownedTokensIndex;
    mapping (uint => address) private tokenOwner;
    mapping(address => uint) private ownedTokensCount;
    mapping(uint => uint) public askOrders; // トークンの値段を格納
    mapping(uint => address) public deposits;  // トークンを売りに出した人のアドレスを格納

    event Transfer(address indexed _from, address indexed _to, uint indexed _tokenId);
    event SellOrdered(address seller, uint id, uint price);
    event BuyOrdered(address seller, address buyer, uint id, uint price);

    // 現在持っているトークンの枚数を返す
    function balanceOf(address _owner) public view returns (uint) {
        return ownedTokensCount[_owner];
    }

    // トークン所有者のアドレスを返す
    function ownerOf(uint _tokenId) public view returns (address) {
        return tokenOwner[_tokenId];
    }

    // 現在売りに出されているトークン一覧を表示する
    // 注文リスト表示
    function getBoard() public view returns (uint[] tokenIdList) {
        uint id = 1;
        uint resultIndex = 0;
        if (onBoardConter == 0) {
            tokenIdList = new uint256[](0);
        } else {
            uint[] memory t = new uint[](onBoardConter);
            for (; id <= tokenCounter; id = id.add(1)) {
                if (tokenOwner[id] != address(0)) {
                    t[resultIndex] = id;
                    resultIndex = resultIndex.add(1);
                }
            }
            tokenIdList = t;
        }
    }

    // トークンの所有権の譲渡
    function transferFrom(address _from, address _to, uint _tokenId) public payable {
        require(_to != address(0));
        require(ownerOf(_tokenId) == _from);
        ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
        tokenOwner[_tokenId] = address(0);
        _addTokenTo(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId);
    }

    // トークンを発行する
    function mint() public returns (bool) {
        tokenCounter = tokenCounter.add(1);
        _mint(msg.sender, tokenCounter);
        return true;
    }

    function _mint(address to, uint tokenId) internal {
        require(to != address(0));
        _addTokenTo(to, tokenId);
        emit Transfer(address(0), to, tokenId);
    }

    function _addTokenTo(address _to, uint _tokenId) internal {
        require(tokenOwner[_tokenId] == address(0));
        tokenOwner[_tokenId] = _to;
        ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
    }

    // トークンを売りに出す
    // 単位は最小単位のwei
    function sellOrder(uint id, uint price) public {
        require(tokenOwner[id] == msg.sender);
        askOrders[id] = price;
        deposits[id] = msg.sender;
        onBoardConter = onBoardConter.add(1);
        transferFrom(msg.sender, address(this), id);
        emit SellOrdered(msg.sender, id, price);
    }

    // トークンを購入する
    function buyOrder(uint id) public payable {
        uint price = msg.value;
        require(askOrders[id] == price);
        address deposit_address = deposits[id];
        delete deposits[id];
        delete askOrders[id];
        onBoardConter = onBoardConter.sub(1);
        transferFrom(address(this), msg.sender, id);
        deposit_address.transfer(price);
        emit BuyOrdered(deposit_address, msg.sender, id, price);
    }
}
