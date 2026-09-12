//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// custom error 
error ZeroAmount(); // when to use this when you have function like deposit(),withdraw(), sendEth()
error InsufficientBalance(uint256 requested, uint256 available); // where to use withdraw(), send Eth()
error TransferFailed();  // where to use withdraw(), send eth()
error StillLocked(); // withdraw

contract SmartVault {

    // Events
    event Deposited(address indexed user, uint256 amount); // help deposit emit to connect to frontend
    event Withdrawn(address indexed user, uint256 amount); // help withdrawn connect to frontend 
    event EthSent(address indexed from, address indexed to, uint256 amount); // help send eth and receive eth connect to frontend
    event Paused(address indexed owner);
    event Unpaused(address indexed owner);

    // variables
    mapping(address => uint256) public balances; // track user balances
    mapping(address => uint256) public unlockTime; // when user can withdraw
    address public owner;
    bool public isPaused;
    uint256 public lockDuration = 30 days; // you can change days and this function do how long to lock

    // constructor
    constructor(uint256 _lockDuration){
    owner = msg.sender;
    lockDuration = _lockDuration; // timeStamp
    }
       
        //modifier

        modifier onlyOwner(){
            require(msg.sender == owner, "Not owner");
            _;
        }
        modifier whenNotPaused(){
            require(!isPaused, "Paused");
            _;
        }

        // pause and unpause functions
        function pause() public onlyOwner{
            isPaused = true;
            emit Paused(msg.sender);
        }
          function unpause() public onlyOwner{
            isPaused = false;
            emit Unpaused(msg.sender);
          }

         // deposit function with gas optimizatio, custom error, security patterns

        function _processDeposit(address _user, uint256 _amount) internal {
            if (_amount == 0) revert ZeroAmount();

            unchecked {
                balances[_user] += _amount;
            }

            unlockTime[_user] = block.timestamp + lockDuration;
            emit Deposited(_user, _amount);
        }

        // public deposit
        function deposit() public payable {
            _processDeposit(msg.sender, msg.value);
        }
        // receive(Direct eth)
        receive() external payable {
            _processDeposit(msg.sender, msg.value);
        }

        // fall back 
        fallback() external payable {
            if (msg.value > 0){
                _processDeposit(msg.sender, msg.value);
            } else {
                revert ("function does not exist");
            }

        }
       
       // withdraw function with gas optimization,custom error, security patterns

       function withdraw(uint256 _amount) public whenNotPaused{
        if(_amount == 0) revert ZeroAmount(); //custom error =  check for ZeroAmount

        uint256 balance = balances[msg.sender]; // gas optimization read balance once
        if(_amount > balance) revert InsufficientBalance(_amount, balance); // custom error if user have enough balance 
        if (block.timestamp < unlockTime[msg.sender]) revert StillLocked(); //if + revert + custom error
        
        // Gas Optimization + Security: Update state FIRST
        unchecked{
            balances[msg.sender] = balance - _amount;
        }

        // Security Pattern: Send ETH LAST (CEI pattern)
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        if(!success) revert TransferFailed();

       emit Withdrawn(msg.sender, _amount); // help to make transaction history of withdrawn 
       }

       function canWithdraw(address _user) public view returns (bool) {
        return block.timestamp >= unlockTime[_user];
       }
       function getContractBalance() public view returns (uint256) {
    return address(this).balance;
}

       // Send Eth function with error InsufficientBalance

       function sendEth(address _friend, uint256 _amount) public {   //_friend -> _to,
        if (_amount == 0) revert ZeroAmount();

        uint256 balance = balances[msg.sender]; // check callers balance ( not contract balance)
        if (_amount > balance) revert InsufficientBalance(_amount, balance);

        unchecked{   // deduct from caller
                   balances[msg.sender] = balance - _amount;
                }
                (bool success, ) = payable(_friend).call{value: _amount}(""); // Send eth to friend /other
                if (!success) revert TransferFailed();

                emit EthSent (msg.sender, _friend, _amount); // help to make transaction history of send eth
             }

       
           }