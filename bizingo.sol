// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Biz{
    int balance;
    constructor() {
        balance = 0;
    }
    function getBalance() view public returns(int){
        return balance;
    }
    function depositBalance(int amt) public{
        balance = balance + amt;
    }

    function withdrawBalance(int amt) public{
        balance = balance - amt;
    }

}