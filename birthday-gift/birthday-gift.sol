pragma solidity ^0.4.0;

// Example Contract that contributors can give birthday gifts to wallet(s)

// Gifter can send money to all pool
// Gifter can send to specifc address
// Birthdayee can see funds
// Birthdayee will not be transfered until birthday

contract BirthdayGift {

    uint giftAllBalance = 0;
    uint numOfWallets = 0;

    struct Birthdayee {
        // fix int
        uint birthDate;
        // fix int
        uint balance;
        // Used to see if address has been initialized
        bool isInitialized;
        // used to limit the withdrawls from address - once
        bool hasTakenPayment;
    }
    
    // All participants
    mapping (address => Birthdayee) birthdayPool;
    
    // function to control counts of pool members
    function isNewAddress(address birthdayeeAddress) private returns(bool) {
        // Has this been initialized
        if ( birthdayPool[birthdayeeAddress].isInitialized ) {
            return true;
        }
        
        return false;
    }
    
    // If the wallet hasn't been initialized, then do so and increment counter
    function walletDoorCheck(address birthdayeeAddress) private {
        if ( isNewAddress(birthdayeeAddress) ) {
            birthdayPool[birthdayeeAddress].isInitialized = true;
            numOfWallets++;
        }
    }
    
    function getGiftBalance(address birthdayeeAddress) private returns(uint) {
        uint payout = birthdayPool[birthdayeeAddress].balance;
        if (birthdayPool[birthdayeeAddress].hasTakenPayment != true){
             uint birthdayeePoolBalance = this.balance / numOfWallets;
             payout += birthdayeePoolBalance;
        }

        return payout;
    }
    
    function resetBalance(address birthdayeeAddress) private {
        birthdayPool[birthdayeeAddress].balance = 0;
        birthdayPool[birthdayeeAddress].hasTakenPayment = false;
    }
    
    // Give to birthday pool because nice people do exist
    function giveAll(uint giftAmount) public payable {
        giftAllBalance += giftAmount;
    }
    
    // Give to a specific wallet
    function giveTo(uint giftAmount, address birthdayeeAddress) public payable {
        walletDoorCheck(birthdayeeAddress);
        birthdayPool[birthdayeeAddress].balance += giftAmount;
    }
    
    // View Birthdayee balance assigned and from pool
    function viewMyGift(address birthdayeeAddress) public returns (uint) {
        walletDoorCheck (birthdayeeAddress);

        return getGiftBalance(birthdayeeAddress);
    }
    
    // Collect birthday gift if within two weeks of birthday
    function collectMyGift(address birthdayeeAddress) public {
        walletDoorCheck(birthdayeeAddress);
        uint payout = getGiftBalance(birthdayeeAddress);
        birthdayeeAddress.transfer(payout);
        require (payout != 0);
        if ( birthdayPool[birthdayeeAddress].hasTakenPayment != true ) {
            giftAllBalance -= payout;
        }
    }


}