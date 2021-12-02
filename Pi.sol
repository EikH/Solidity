/**
 *Submitted for verification at hecoinfo.com on 2021-04-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
	
	uint8 private _decimals = 18;
    uint256 private _totalSupply = 100 * (10 ** uint256(18));
	
	constructor(string memory name_,string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _balances[msg.sender] += 1 * (10 ** uint256(18));
        emit Transfer(address(0), msg.sender, 1 * (10 ** uint256(18)));
    }
  
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
	
    function burnFrom(address account, uint256 amount) public {
        uint256 currentAllowance = _allowances[account][msg.sender];
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, msg.sender, currentAllowance - amount);
        _burn(account, amount);
    }
	
	
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        require(amount + totalSupply() < 100000 * (10 ** uint256(18)));
        _balances[account] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), account, amount);

    }

}

contract LPToken is ERC20("TK","Token"){
    uint256 private endtime = 2 seconds;
    address own = msg.sender;
    address payable acceptAddress = payable(msg.sender);
    uint reward = 1;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public recommend;
    mapping(address => uint256) public Ownstart;
    mapping(address => bool) private existence;
    
    event Staked(address indexed user, uint256 amount);

    modifier master() {
        require(msg.sender == own,"EOFF");
        _;
    }

    function setReward(uint256 reward_) public master{
        reward = reward_;
    }

    function setTime(uint256 times) public master {
        endtime = times;
    }

    function setOwn(address own_) public master {
        own = own_;
    }

    function setAcceptAddress(address acceptAddress_) public master {
        acceptAddress = payable(acceptAddress_);
    }

    function  stake() payable public  {
        uint _reward;
        require(block.timestamp - Ownstart[msg.sender] > endtime);
        acceptAddress.transfer(0.004 ether);
        _reward = reward + recommend[msg.sender];
        Ownstart[msg.sender]  = block.timestamp;
        deposits[msg.sender] = deposits[msg.sender] + _reward;
    }

    function stake(address recommend_) payable public  {
        uint _reward;
        require(!existence[msg.sender]);
        require(recommend_ != msg.sender);
        require(block.timestamp - Ownstart[msg.sender] > endtime);
        acceptAddress.transfer(0.004 ether);
        if (recommend[msg.sender] < 4) {
            recommend[recommend_] += 1;
        }
        existence[msg.sender] = true;
         _reward = reward + recommend[msg.sender];
        Ownstart[msg.sender]  = block.timestamp;
        deposits[msg.sender] = deposits[msg.sender] + _reward;
    }
    
    function myReceive() public {
        require(Ownstart[msg.sender] + 1 days >= block.timestamp,"EOFF time is not up!");
        uint amount_ = deposits[msg.sender] *(10 ** uint256(18));
        deposits[msg.sender] = 0;
        _mint(msg.sender,amount_);
    }

}