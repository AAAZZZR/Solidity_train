//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Auction{
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;

    enum state{Started, Running, Eneded, Canceled}
    state public auctionState;

    //ceiling price
    uint public highestBindingBid;

    address payable public highestBidder;
    mapping(address => uint) public bids;
    uint bidIncrement;// minimum gap between each bids

    bool public ownerFinalized = false;

    constructor(){
        owner = payable(msg.sender);
        auctionState = state.Running;

        startBlock = block.number;
        endBlock = startBlock + 3;

        ipfsHash = "";
        bidIncrement = 1000000000000000000;
    }

        modifier notOwner(){
            require(msg.sender != owner);
            _;
        }

        modifier onlyOwner(){
            require(msg.sender == owner);
            _;
        }

        modifier afterStart(){
            require(block.number >= startBlock);
            _;
        }

        modifier beforeEnd(){
            require(block.number <= endBlock);
            _;
        }

        function min(uint a, uint b) pure internal returns(uint){
            if(a <= b){
                return a;
            }else{
                return b;
            }

        }//you can also import math file 

        function cancelAuction() public beforeEnd onlyOwner{
            auctionState = state.Canceled;
        }

        function placeBid() public payable notOwner afterStart beforeEnd returns(bool){
            require(auctionState == state.Running);

            uint currentBid = bids[msg.sender] + msg.value;//default is zero

            require (currentBid > highestBindingBid);

            bids[msg.sender] = currentBid;

            /**
            highestbindingbid is the min price to make a bid
             */
            if (currentBid <= bids[highestBidder]){
                highestBindingBid = min(currentBid+bidIncrement,bids[highestBidder]);
            }else{
                highestBindingBid = min(currentBid,bids[highestBidder] + bidIncrement);
                highestBidder = payable(msg.sender);
            }
            return true;
        }

        function finalizedAuction() public{
            require (auctionState == state.Canceled || block.number > endBlock);

            require(msg.sender == owner || bids[msg.sender] >0);

            address payable recipient;
            uint value;

            if (auctionState == state.Canceled){//Auction cancel.Bring your money back
                recipient = payable(msg.sender);
                value = bids[msg.sender];
                
            }else{
                // Auction end
                if(msg.sender == owner && ownerFinalized == false){
                    recipient = owner;
                    value = highestBindingBid;
                    ownerFinalized = true;
                }else{
                    if (msg.sender == highestBidder){
                        recipient = highestBidder;
                        value = bids[highestBidder] - highestBindingBid;// highestbindingbid is the fanal price, not bids[highestBidder].
                    }else{//other people can bring their money back
                        recipient = payable(msg.sender);
                        value = bids[msg.sender];
                    }
                }
            }

            bids[recipient] = 0;
            recipient.transfer(value);
        }
}