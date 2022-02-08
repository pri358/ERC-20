// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract MyErc20 {

    string NAME = "oatsToken";
    string SYMBOL = "OAT";
    mapping(address => uint) balances;

    address deployer;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping(uint => bool) blockMined;

    mapping(address => mapping(address => uint)) allowances;
    // allowances[user1][user2] = 10; implies user1 has approved user2 to spend 10 coins.

    uint totalMinted = 1000000 * 1e8;

    constructor() {
        deployer = msg.sender;
        balances[deployer] = 1000000 * 1e8;
    }
    
    function name() public view returns (string memory){
        return NAME;
    }
    
    function symbol() public view returns (string memory) {
        return SYMBOL;
    }
    
    function decimals() public view returns (uint8) {
        return 8;
    }
    
    function totalSupply() public view returns (uint256) {
        return 10000000 * 1e8;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        assert(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        assert(balances[_from] > _value);
        assert(allowances[msg.sender][_from] >= _value);
        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value; 
        allowances[msg.sender][_from] = allowances[msg.sender][_from] - _value; 

        emit Transfer(_from, _to, _value);

        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    function getCurrentBlock() public view returns(uint){
        return block.number;
    }
    
    function isMined(uint blockNumber) public view returns(bool) {
        return blockMined[blockNumber];
    }

    function mine() public returns (bool success){
        assert(!blockMined[block.number]);
        assert(totalMinted + 10*1e8 <= totalSupply());
        balances[msg.sender] = balances[msg.sender] + 10*1e8;
        totalMinted = totalMinted + 10*1e8;
        return true;
    }

    function sqrt(uint x) internal returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return z;
    }
    
    function square(uint x) internal returns(uint) {
      return x*x;
    }

    function calculateMint(uint amountInWei) internal returns(uint) {
      return sqrt((amountInWei * 2) + square(totalMinted)) - totalMinted;
    }

    // n = number of coins returned 
    function calculateUnmint(uint n) internal returns (uint) {
        return (square(totalMinted) - square(totalMinted - n)) / 2;
    }
    
    function mint() public payable returns(uint){
      uint coinsToBeMinted = calculateMint(msg.value);
      assert(totalMinted + coinsToBeMinted < 10000000 * 1e8);
      totalMinted += coinsToBeMinted;
      balances[msg.sender] += coinsToBeMinted;
      return coinsToBeMinted;
    }
    
    function unmint(uint coinsBeingReturned) public payable {
      uint weiToBeReturned = calculateUnmint(coinsBeingReturned);
      assert(balances[msg.sender] > coinsBeingReturned);
      payable(msg.sender).transfer(weiToBeReturned);
      balances[msg.sender] -= coinsBeingReturned;
      totalMinted -= coinsBeingReturned;
    }
    
    
}
