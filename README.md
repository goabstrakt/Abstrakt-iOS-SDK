# Abstrakt iOS Blockchain SDK

Abstrakt's SDK, is a plug & play blockchain interface for your iOS application. Our SDK takes the responsibility of developing, managing, and maintaining much of the essential infrastructure critical for blockchain dapp development. For a high level overview of what our SDK offers, checkout https://goabstrakt.com/sdk/ 

This documentation can also be viewed here: http://abstakt.docs.stoplight.io. 

## Requirements

- iOS 11+
- Xcode 9+
- Swift 4.x

## Setup

1. Create pod file and add below dependancies using [CocoaPods](https://guides.cocoapods.org/using/getting-started.html). Replace **SDKTestApp** with your app name.
   
 ```
 platform :ios, '11.0'

target 'SDKTestApp' do
  use_frameworks!

  pod 'Abstrakt', :git => 'https://github.com/goabstrakt/Abstrakt-iOS-SDK.git'
end
```
2. Then run the following command:
    ``` $ pod install ```

3. Create a file named `Auth0.plist` on the root of your project. Add the following code in the file (replacing the `YOUR_CLIENT_ID` and `YOUR_DOMAIN` with the values provided by Abstrakt):
```<!-- Auth0.plist -->

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>ClientId</key>
        <string>YOUR_CLIENT_ID</string>
        <key>Domain</key>
        <string>YOUR_DOMAIN</string>
    </dict>
</plist>
```
Default Limited ClientId & URL for testing: 
    **ClientId:** GTagntKIIbH48Oi2Cultj7243mGTwCnr
    **Domain  :** vaultwallet.auth0.com


**Note:** `Abstrakt.shared` is used to access the Abstrakt framework as singleton. Currently all functions need to be accessed using **'.shared'**

## Abstrakt SDK Primitive Concepts

This section covers the powerful features built into Abstrakt SDK. 

#### User Accounts 
A user account is created using a unique identifier generated by oAUTH authentication. Applications can easily on-board users with their existing Facebook/Google/etc logins. You can think of a user account as the parent to all other data. A user account associates users' public keys with human readable names, keeps track of a users' contacts and stores metadata (name, email, avatar, phone number). **Mnemonics/Private keys are never stored or transmitted to Abstrakt**. Mnemonics are securely generated by the client side SDK and are backed up by the user. Mnemonics can be imported by the user as well. Users can create unlimited 'Wallet Accounts' of any supported blockchain from their mnemonic. When a user is deleted from the device, the SDK deletes all user data including accounts, mnemonic, private keys, cached transaction information. 

#### Accounts 
A 'wallet account' is a single public + private key pair & associated metadata. An account is 'named' by user on creation. Conceptually, you can think of this as a child object of a User Account, because each account is associated with a User. 
> `Account` is an object representing the `publicAddress`, `blockchainId` and `nickname` 

#### Shared Accounts
A shared account is a wallet account that is shared by a user to another user via a 'connection'. Only the public key & nickname is shared with the other user. Private keys always remain encrypted on the user's device. Shared accounts allow users to transact with each other without external communication of public addresses which is error prone, insecure, and unacceptable UX.
> `SharedAccount` is an object representing the `publicAddress`, `blockchainId`, `nickname`, and `otherUserId`

#### Connections
Connections are basically 'friends'. Connections can be sent, received, accepted, denied and removed. Flow: User searches for another user by querying a name, email using the SDK. Next, the user sends a connection request to the userId found. The otherUser can choose to accept or decline the connection. Finally the users can share accounts and begin transacting. Note that users include: peers, businesses, merchants etc. - anyone integrating with Abstrakt.

#### Market Data
The SDK provides real-time market data for all supported blockchains in USD. Application developers don't have to worry about other data sources.  More currencies denominations will be added. (EUR, KRW etc.) 

#### Transaction Data
Abstrakt provides rich transaction data from all supported blockchains. When a user adds a wallet account, all historical transactions associated with that account will be sent to the user. Smart contract data is coming soon.

#### Caching Data
Abstrakt SDK automatically caches all user data on the client device! As a result, application developers have access to all synced user data `offline`. This is a significant performance and user experience improvement for your application!

## QuickStart
This sample code demonstrates how to autheticate a user and call SDK functions onces the framework is setup. 

*Note:* Abstrakt.**shared** is used to access the Abstrakt framework as singleton. Currently all functions need to be accessed using **'shared'**
```swift

import UIKit
import AbstraktSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // Step 1: Authenticate user to abstrakt services 
        Abstrakt.shared.authenticateWithEmailAndPassword(email: "daniel@testgmail.com", password: "testingpassword", completion: { (status) in
            if status == "success" {
                print("Authenticated successfully")
            } else {
                print("failed to authenticate")
            }
        }


        // Step 2: Generate new mnenonic seed for user. User must save the mnemonic. Mnemonic is required to recover account.
        let generatedMnemonic = Abstrakt.shared.createMnemonic()

        // Step 3: Generate ethereum account from mnemonic  
        let nickName = "AccountName"
        Abstrakt.shared.createAccount(nickName: nickName, blockchainNetwork: BlockchainNetwork.EthMainnet)  { (status) in
            if status {
                print("Account created successfully")
            } else {
                print("Failed to create account")
            }
        }

        // Step 4: Check your created accounts
        Abstrakt.shared.getMyAccounts(isTestnetEnabled: false) { (accounts) in
            print("account count \(accounts.count)")                
        }

        // Deletes all local data including user mnemonic, accounts and cached data. Make sure user has backed up mnemonic before logout
        Abstrakt.shared.logout(); 
        
    }

    
}
```

## SDK integration guidelines and best practices

- The current SDK is accessed as a singleton. All functions called through **Abstrakt.shared**.
- The Authenicate function must be called first to connect the SDK to supported blockchains. Authenticate estabilishes a real-time connection with Abstrakt's services. For more information about our real-time MQTT connection, checkout the features section. 

- The SDK provides 2 types of interfaces to access blockchain data, accounts & connections:
    1) function calls - returns data via completion block
    2) delegates      - returns data whenever there are any changes

    - We recommend using fuction calls to **initializing** UI and 'get' specific data for one-time consumption.
    - We recommend listening to delegates to **update** UI and/or trigger actions. Delegates push new data (transactions, account updates, etc.) to all functions calling it. 


## Authentication

Authentication functions to login/logout, get user info and check status.

#### Authenticate user
These functions authenticate the user and connect the client via MQTT to Abstrakt'a services.

Login/Create new user account by authenticating with Auth0. This function creates a new account for new users and logs in existing users. 
<table>
  <tr><th><b>Parameter</b></th><th><b>Description</b></th></tr>
  <tr><td>email</font></td><td>username & email of user</td></tr>
  <tr><td>password</td><td>user password must have at least 8 characters, 1 lower case, 1 upper case, 1 special character</td></tr>
  <tr><th><b>Return</b></th><th><b>Description</b></th></tr>
  <tr><td>string</td><td>returns *success* or *nil* if authentication failed</td></tr>
</table>

```swift
Abstrakt.shared.authenticateWithEmailAndPassword(email: String, password: String, completion: @escaping (String) -> Void)
```
Login/Create new user account by authenticating with Auth0 social auth. This function redirects the user to a social authentication login.
<table>
  <tr><th><b>Parameter</b></th><th><b>Description</b></th></tr>
  <tr><td>audience</td><td>auth0 API url that your application will use for authentication. Don't set parameter to use default value.</td></tr>
  <tr><th><b>Return</b></th><th><b>Description</b></th></tr>
  <tr><td>string</td><td>returns *success* or *nil* if authentication failed</td></tr>
</table>

```swift
Abstrakt.shared.authenticate(audience: String, completion: @escaping (String?) -> Void)
````

#### Check if user is already authenticated
```swift
Abstrakt.shared.hasCredentials() -> Bool
```
#### Get User's Id
```swift
Abstrakt.shared.getUserId() -> String
```
#### Get User Avatar
```swift
Abstrakt.shared.getUserAvatar() -> String
```
#### Get User Name
```swift
Abstrakt.shared.getUserName() -> String
```
#### Get User Email
```swift
Abstrakt.shared.getUserEmail() -> String
```
#### Logout and Wipe all local stored data
```swift
Abstrakt.shared.logout()
```

## Network Connectivity 
Check if SDK is connected to Abstrakt Services
```swift
Abstrakt.shared.getConnectionStatus() -> Bool
```

## Mnemonic
A mnemonic is a human readable list of words that generates a master seed, that in turn, generates wallet accounts for users. It is critical that a mnemonic must be backed-up by the user, as soon as it is generated. If the user's account is deleted from their device, or if the device is lost, the mnemonic is not recoverable! It is the key to accessing a user's wallet accounts. We are working on cloud-backup using the iOS/Android keystore for users with smaller account balances.

#### Generate a Mnemonic seed  
Creates a random mnemonic string. Returned string can be displayed to the user for backup. 
*After calling `createMnemonic`, call `createAccount` to create the first account using this mnemonic.*
```swift
Abstrakt.shared.createMnemonic() -> String
```
#### Import Mnemonic 
This function imports an mnemonic to the device. The user can type in their mnemonic and recover previously generated accounts or import accounts from another device.
**Two Cases:**
1. The user already has accounts previously created from this menmonic in SDK. (function `getMyAccounts` returns accounts)
    * In this case, private keys of existing accounts are automatically generated using the imported menmonic.
2. The user does not have existing accounts generated earlier. 
    * In this case, *nickName* and *blockchainNetwork* can be set to create first account. If unset, defaults will be used to create first account. 

*Note: only one mnemonic is support at this time. multi-mnemonic support will be added soon.*

<table>
  <tr><th><b>Parameter</b></th><th><b>Description</b></th></tr>
  <tr><td>isTestnetEnabled</td><td>if enabled will generate testnet work accounts and mainnet accounts of existing accounts</td></tr>
  <tr><td>mnemonic</td><td>mnemonic string to import</td></tr>
  <tr><td>nickName</td><td>optional name of first account created using mnemonic. Both blockchainNetwork and nickName have to be specifed or either.</td></tr>
  <tr><td>blockchainNetwork</td><td>optional blockchain network of first account created.</td></tr>
  <tr><th><b>Return</b></th><th><b>Description</b></th></tr>
  <tr><td>boolean</td><td>returns true = success or false = failed</td></tr>
</table>

```swift
Abstrakt.shared.importMnemonic(isTestnetEnabled: Bool = false, mnemonic: String, nickName: String, blockchainNetwork: BlockchainNetwork, completion: @escaping (Bool) -> Void)
```
#### Get Mnemonic
This function returns generated/imported menmonic encrypted on the device. It can be displayed to the user for backing up. 
```swift
Abstrakt.shared.getMnemonic(completion: @escaping (String) -> Void)
```
#### Cloud backup (work in progress..)
This function will enable you to encrypt the user generated mnenomnic with a password and store it to the apple keychain. 
#### Recover cloud backup (work in progress..)
Once a mnenomic is encrypted and backuped to the user's apple keychain, it can be recovered automatcially on future logins. 

## Account Management 
#### Generate Account public/private keypair from a Mnemonic
Create account can be called after generating or importing the mnemonic which is the master seed. If the mnemonic does not exist on device, an error will be returned. 
```swift
Abstrakt.shared.createAccount(nickName: String, blockchainNetwork: BlockchainNetwork, completion: @escaping (CompletionError?, Account?) -> Void)
```
#### Remove Account
Removing an account deletes the private/public key pair from the device and from the user's profile. 
Note that deleting the last account, will delete the mnemonic that was used to generate the account as well. Hence, if the last account is deleted, all private keys and mnemonics are deleted from device. 
```swift
Abstrakt.shared.removeAccount(blockchainNetwork: BlockchainNetwork, accountAddress: String, completion: ((CompletionError?, _ accountAddress: String?) -> Void)? = nil)
```
#### Get Account Balance
This function gets the account balance of any account the logged in user has in their acccount.
```swift
Abstrakt.shared.getAccountBalance(accountAddress: String, blockchainNetwork: BlockchainNetwork, completion: @escaping (_ accountBalance: Double, _ accountConversionBalance: Double) -> Void)
```
#### Get Account Object
Return Account Object 
```swift
Abstrakt.shared.getMyAccounts(isTestnetEnabled: Bool, completion: @escaping ([Account]) -> Void)
```
#### Share Account
```swift
Abstrakt.shared.shareAccount(userId: String, blockchainNetwork: BlockchainNetwork, accountAddress: String, completion: ((CompletionError?, Account?) -> Void)? = nil)
```
#### Unshare Account
```swift
Abstrakt.shared.unshareAccount(userId: String, blockchainNetwork: BlockchainNetwork, accountAddress: String, completion: ((CompletionError?, Account?) -> Void)? = nil)
```
#### Get Shared Account From Other User's UserId
```swift
Abstrakt.shared.getSharedAccountFromUserId(userId: String, completion: @escaping ([Account]) -> Void)
```
#### Get Account Keys
Work in Progress - Will return public & private keys of specified account


## Transactions 
#### Get Transactions from all accounts of specified blockchain networks 
```swift
Abstrakt.shared.getTransactions(blockchainNetwork: [Strings], completion: @escaping ([EthereumTransaction]) -> Void)
```
####  Get Transactions from a specific account
```swift
Abstrakt.shared.getTransactionsFromAccount(accountAddress: String, blockchainNetwork: BlockchainNetwork, completion: @escaping ([EthereumTransaction]) -> Void)
```
#### Get Pending Transactions from all accounts of specified blockchain networks 
```swift
Abstrakt.shared.getPendingTransactions(blockchainNetworks: [BlockchainNetwork] = [], completion: @escaping ([EthereumTransaction]) -> Void)
```
####  Get Transactions from a specific account
```swift
Abstrakt.shared.getPendingTransactionsFromAccount(accountAddress: String, blockchainNetwork: BlockchainNetwork, completion: @escaping ([EthereumTransaction]) -> Void)
```
#### Send Transaction
Send transaction by specifying the from address, to address, the blockchain network, and value in ether.   

<table>
  <tr><th><b>Parameter</b></th><th><b>Description</b></th></tr>
  <tr><td>blockchainNetwork</td><td>if enabled will generate testnet work accounts and mainnet accounts of existing accounts</td></tr>
  <tr><td>fromAccountAddress</td><td>public address of account to transfer from</td></tr>
  <tr><td>toAccountAddress</td><td>public address of account to transfer to</td></tr>
  <tr><td>amountToTransfer</td><td>amount in ether to transfer</td></tr>
  <tr><th><b>Return</b></th><th><b>Description</b></th></tr>
  <tr><td>boolean</td><td>returns true = success or false = failed</td></tr>
</table>

```swift
Abstrakt.shared.sendTransaction(blockchainNetwork: BlockchainNetwork, fromAccountAddress: String, toAccountAddress: String, userId: String, amountToTransfer: String, completion: @escaping (CompletionError?) -> Void)
```

## Market Data
Returns the USD market value of the specified blockchain network
```swift
Abstrakt.shared.getMarketValue(by blockchainNetwork: BlockchainNetwork) -> MarketValue?
```

## Connections 
```swift
Abstrakt.shared.searchContact(email: String, completion: @escaping (CompletionError?, [SearchedContact]) -> Void)
```
```swift
Abstrakt.shared.getPendingConnectionRequests(completion: @escaping ([PendingConnectionRequest]) -> Void)
```
```swift
Abstrakt.shared.requestConnection(userId: String, completion: ((CompletionError?, PendingConnectionRequest?) -> Void)? = nil)
```
```swift
Abstrakt.shared.approveConnectionRequest(userId: String, completion: ((CompletionError?, UserConnection?) -> Void)? = nil)
```
```swift
Abstrakt.shared.denyConnectionRequest(userId: String, completion: ((CompletionError?, _ userId: String?) -> Void)? = nil)
```
```swift
Abstrakt.shared.removeConnection(userId: String, completion: ((CompletionError?, _ userId: String?) -> Void)? = nil)
```
```swift
Abstrakt.shared.getConnections(completion: @escaping ([UserConnection]) -> Void)
```


## Delegates 
Delegates are triggered when there is a state change in any of the Abstrakt Objects.
Delegates return the new data received by the logged-in user, **on all devices**. If the user is logged-in on 2 devices, delegates on both devices will be triggered!
####  Monitor connectivity to abstrakt services 
```swift
didConnected()                                                          // Connected to Abstrakt's Services 
didDisconnected()                                                       // Disconnected from Abstrakt's Services (user closed the app or no internet connectivity)
```
####  New Transactions and Market Data
```swift
newTransaction(transaction: EthereumTransaction)
marketValueUpdated(newValue: MarketValue)
```
####  Accounts
```swift
accountNickNameChanged(account: Account) {}                             
accountAdded(account: Account) {}
accountRemoved(accountAddress: String) {}

accountShared(account: Account) {}                   // returns an account that was shared by logged-in user or other user. 'isMyAccount' show who.
accountUnshared(account: Account) {}                 // returns an account that was unshared by logged-in user or other user. 'isMyAccount' show who. 
```

#### Connections
```swift
connectionRequestSent(connectionRequest: PendingConnectionRequest) {}   // returns pending connection request initiated by other user for the logged-in user
newConnectionRequest(connectionRequest: PendingConnectionRequest) {}    // returns pending connection request initiated by logged-in user. request could have been initiated by user on another device. 
connectionRequestAccepted(connection: UserConnection) {}                // returns 'approved' connection for a pending connection request initiated by logged-in user
connectionRequestAcceptedByMe(connection: UserConnection) {}            // returns 'approved' connection for a pending connection request initiated by other user. logged-in user accepted the request. 
connectionRequestDenied(userId: String) {}                              // returns other userId of a pending connection requested that was declined/cancelled 
connectionRemoved(userId: String) {}                                    // returns other userId of an existing connection that was removed
```








