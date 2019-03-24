pragma solidity ^0.4.24;
contract TokenERC20 {
    string public name; // トークン名
    string public symbol; // トークンを表す記号
    uint8 public decimals = 18; // 10の何乗を1トークンとするか
    uint256 public totalSupply; // トークンの総供給量
    address public owner;
    mapping (address => uint256) public balances; // アドレスごとのトークン残高
    mapping (address => mapping (address => uint256)) public allowed; // トークンを送金できる最大量
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // コンストラクタでは,
    // initialSupply = 初期供給（発 行）量,
    // tokenName = トークン名,
    // tokenSymbol = トークンを表す記号,
    // の三つの変数を渡して初期化.
    constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
        owner = msg.sender; // コントラクト製作者のアドレス
    }
    // totalSupply() は総供給量を返却する view 関数.
    function totalSupply() public view returns (uint256) {
        return (totalSupply);
    }
    // balanceOf(address _owner) は指定されたアドレスの保有するトークン残高を
    // 返却する view 関数.
    function baranceOf(address _owner) public view returns (uint256) {
        return (balances[_owner]);
    }
    // _transfer(...) は _from から _to への _value だけのトークンの送金を
    // 実際に行う内部 (internal) 関数.
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0); //送金先が普通のアドレスであること
        require(balances[_from] >= _value); //残高が送金額より大きいことを確認
        require(balances[_to] + _value > balances[_to]); //送金で残高が減らないことを確認
        uint previousBalances = balances[_from] + balances[_to]; //合計値
        uint fee = _value / 100; // 手数料
        balances[_from] -= _value; //送信者の残高を減らし
        balances[_to] += _value; //受信者の残高を増やす
        if(_from != owner) {
            balances[_from] -= fee;
            balances[owner] += fee;
            assert(balances[_from] + balances[_to] + fee == previousBalances);
        } else {
            assert(balances[_from] + balances[_to] == previousBalances);
        }
        emit Transfer(_from, _to, _value);
        // assert(balances[_from] + balances[_to] + balances[owner] == previousBalances);
    }
    // transfer(...) はトランザクション作成者 (msg.sender) から指定されたアドレスに
    // トークンの送金を行う関数.
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    // transferFrom(...) は、allowed 変数で許可された送金数量を上限として,
    // _from から _to に対して _value だけの量の送金を行う.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    // approve(...) は allowed に対して送金可能数量を更新する関数.
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    // allowance(...) は allowed の中身を返却する関数.
    // owner が _spender にどのくらいのそ送金を許しているかを確認する関数.
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return (allowed[_owner][_spender]);
    }
}
