//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract lottery{
    address public manager;
    address payable[] public players;

    constructor(){
        manager = msg.sender;
    }

    receive () external payable{
        require(msg.value == 0.1 ether,"Insufficient amounts!");
        players.push(payable(msg.sender));
    }

    function get_balance() public view returns(uint){
        //require(msg.sender == manager);
        return address(this).balance;
    }

    function get_random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players.length)));
    }

    function pick_winner() public{
        require(msg.sender == manager);
        require(players.length >= 3);

        uint r = get_random();
        address payable winner;

        uint index = r % players.length;
        winner = players[index];

        winner.transfer(get_balance());
        players = new address payable[](0);
    }
}