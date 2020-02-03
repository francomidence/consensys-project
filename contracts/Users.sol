pragma solidity >=0.4.21 <0.7.0;

contract Users {
    // data structure that stores a user
    struct User {
        string name;
        bytes32 status;
        address walletAddress;
        uint256 createdAt;
        uint256 updatedAt;
    }

    // it maps the user's wallet address with the user ID
    mapping(address => uint256) public usersIds;

    // Array of User that holds the list of users and their details
    User[] public users;

    // event fired when an user is registered
    event newUserRegistered(uint256 id);

    // event fired when the user updates his status or name
    event userUpdateEvent(uint256 id);

    // Modifier: check if the caller of the smart contract is registered
    modifier checkSenderIsRegistered {
        require(isRegistered());
        _;
    }

    /**
     * Constructor function
     */
    constructor() public {
        // the first user must be emtpy
        addUser(address(0x0), "", "");

        // dummy data
        addUser(address(0x333333333333), "Hi Consensys :)", "Available");
    }

    /**
     * Function to register a new user.
     *
     * @param _userName 		The displaying name
     * @param _status        The status of the user
     */
    function registerUser(string memory _userName, bytes32 _status)
        public
        returns (uint256)
    {
        return addUser(msg.sender, _userName, _status);
    }

    /**
     * Add a new user. This function must be private because an user
     * cannot insert another user on behalf of someone else.
     *
     * @param _wAddr 		Address wallet of the user
     * @param _userName		Displaying name of the user
     * @param _status    	Status of the user
     */
    function addUser(address _wAddr, string memory _userName, bytes32 _status)
        private
        returns (uint256)
    {
        // checking if the user is already registered
        uint256 userId = usersIds[_wAddr];
        require(userId == 0);

        // associating the user wallet address with the new ID
        usersIds[_wAddr] = users.length;
        uint256 newUserId = users.length++;

        // storing the new user details
        users[newUserId] = User({
            name: _userName,
            status: _status,
            walletAddress: _wAddr,
            createdAt: now,
            updatedAt: now
        });

        // emitting the event that a new user has been registered
        emit newUserRegistered(newUserId);

        return newUserId;
    }

    /**
     * Update the user profile of the caller of this method.
     * Note: the user can modify only his own profile.
     *
     * @param _newUserName	The new user's displaying name
     * @param _newStatus 	The new user's status
     */
    function updateUser(string memory _newUserName, bytes32 _newStatus)
        public
        checkSenderIsRegistered
        returns (uint256)
    {
        uint256 userId = usersIds[msg.sender];

        User storage user = users[userId];

        user.name = _newUserName;
        user.status = _newStatus;
        user.updatedAt = now;

        emit userUpdateEvent(userId);

        return userId;
    }

    /**
     * Get the users profile information.
     *
     * @param _id 	The ID of the user stored on the blockchain.
     */
    function getUserById(uint256 _id)
        public
        view
        returns (uint256, string memory, bytes32, address, uint256, uint256)
    {
        // checking if the ID is valid
        require((_id > 0) || (_id <= users.length));

        User memory i = users[_id];

        return (
            _id,
            i.name,
            i.status,
            i.walletAddress,
            i.createdAt,
            i.updatedAt
        );
    }

    /**
     * Return profile info of the caller.
     */
    function getOwnProfile()
        public
        view
        checkSenderIsRegistered
        returns (uint256, string memory, bytes32, address, uint256, uint256)
    {
        uint256 id = usersIds[msg.sender];

        return getUserById(id);
    }

    /**
     * Check if the user that is calling smart contract is registered
     */
    function isRegistered() public view returns (bool) {
        return (usersIds[msg.sender] > 0);
    }

    /**
     * Return the number of total registered users.
     */
    function totalUsers() public view returns (uint256) {
        return users.length - 1;
    }

}
