pragma solidity ^0.4.23; //^0.5.10 is vscode compiler version
contract Demo {
 uint public balance;
 // Initialize global variables
 constructor() public 
 {
  balance = 0;
 }
 // The payable keyword allows this function to accept Ether
 function contribute() public payable
 {
  // msg.value is the value of Ether sent in a transaction
  balance += msg.value;
 }
}