//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


error ZeroAmount(); 
error InsufficientBalance(uint256 requested, uint256 available);
error TransferFailed();  
error StillLocked(); 

contract SmartVault {

    event Deposited(address indexed user, uint256 amount); 
    event Withdrawn(address indexed user, uint256 amount); 
    event EthSent(address indexed from, address indexed to, uint256 amount);
    event Paused(address indexed owner);
    event Unpaused(address indexed owner);

    mapping(address => uint256) public balances; 
    mapping(address => uint256) public unlockTime; 
    address public owner;
    bool public isPaused;
    uint256 public lockDuration = 30 days;

    constructor(uint256 _lockDuration){
    owner = msg.sender;
    lockDuration = _lockDuration; 
    }

        modifier onlyOwner(){
            require(msg.sender == owner, "Not owner");
            _;
        }
        modifier whenNotPaused(){
            require(!isPaused, "Paused");
            _;
        }

        function pause() public onlyOwner{
            isPaused = true;
            emit Paused(msg.sender);
        }
          function unpause() public onlyOwner{
            isPaused = false;
            emit Unpaused(msg.sender);
          }

        function _processDeposit(address _user, uint256 _amount) internal {
            if (_amount == 0) revert ZeroAmount();

            unchecked {
                balances[_user] += _amount;
            }

            unlockTime[_user] = block.timestamp + lockDuration;
            emit Deposited(_user, _amount);
        }

        function deposit() public payable {
            _processDeposit(msg.sender, msg.value);
        }
        receive() external payable {
            _processDeposit(msg.sender, msg.value);
        }

        fallback() external payable {
            if (msg.value > 0){
                _processDeposit(msg.sender, msg.value);
            } else {
                revert ("function does not exist");
            }

        }

       function withdraw(uint256 _amount) public whenNotPaused{
        if(_amount == 0) revert ZeroAmount();

        uint256 balance = balances[msg.sender];
        if(_amount > balance) revert InsufficientBalance(_amount, balance); 
        if (block.timestamp < unlockTime[msg.sender]) revert StillLocked(); 

        unchecked{
            balances[msg.sender] = balance - _amount;
        }

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        if(!success) revert TransferFailed();

       emit Withdrawn(msg.sender, _amount); 
       }

       function canWithdraw(address _user) public view returns (bool) {
        return block.timestamp >= unlockTime[_user];
       }
       function getContractBalance() public view returns (uint256) {
    return address(this).balance;
}
         function sendEth(address _friend, uint256 _amount) public {  
        if (_amount == 0) revert ZeroAmount();

        uint256 balance = balances[msg.sender]; 
        if (_amount > balance) revert InsufficientBalance(_amount, balance);

        unchecked{  
                   balances[msg.sender] = balance - _amount;
                }
                (bool success, ) = payable(_friend).call{value: _amount}("");
                if (!success) revert TransferFailed();

                emit EthSent (msg.sender, _friend, _amount); 
             }

       
           }
