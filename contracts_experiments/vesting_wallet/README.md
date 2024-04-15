# Vesting Wallet

VestingWallet handles the maturation (vesting) of cryptocurrency for a given beneficiary.

The constructor specifies the address of the beneficiary, the first timestamp where the beneficiary 
can withdraw funds, and the overall duration of the vesting scheme. 

Once the scheme is expired, the beneficiary can withdraw all the funds from the contract. 
At any moment between the start and the expiration of the vesting scheme, the beneficiary can withdraw 
an amount of tokens proportional to the time passed since the start of the scheme. 

The contract can receive tokens at any time through the receive function: these funds will follow 
the vesting schedule as if they were deposited from the beginning.