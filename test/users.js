var Users = artifacts.require('./Users.sol');

contract('Users', function(accounts) {
  var instance = null;
  var mainAccount = accounts[0];
  var anotherAccount = accounts[1];

  it('should register an user', function() {
    var usersBeforeRegister = null;

    return Users.deployed()
      .then(function(contractInstance) {
        instance = contractInstance;

        return instance.totalUsers.call();
      })
      .then(function(result) {
        usersBeforeRegister = result.toNumber();

        return instance.registerUser('Test User Name', 'Test Status', {
          from: mainAccount
        });
      })
      .then(function(result) {
        return instance.totalUsers.call();
      })
      .then(function(result) {
        assert.equal(
          result.toNumber(),
          usersBeforeRegister + 1,
          'number of users must be (' + usersBeforeRegister + ' + 1)'
        );

        return instance.isRegistered.call();
      })
      .then(function(result) {
        assert.isTrue(result);
      });
  });

  it('username and status in the blockchian should be the same the one gave on the registration', function() {
    return instance.getOwnProfile.call().then(function(result) {
      assert.equal(result[1], 'Test User Name');
      let newStatusStr = web3.toAscii(result[2]).replace(/\u0000/g, '');
      assert.equal(newStatusStr, 'Test Status');
    });
  });
  it('should update the profile', function() {
    return instance
      .updateUser('Updated Name', 'Updated Status', {
        from: mainAccount
      })
      .then(function(result) {
        return instance.getOwnProfile.call();
      })
      .then(function(result) {
        assert.equal(result[1], 'Updated Name');
        let newStatusStr = web3.toAscii(result[2]).replace(/\u0000/g, '');
        assert.equal(newStatusStr, 'Updated Status');
      });
  });

  it('a registered user should not be registered twice', function() {
    return instance
      .registerUser('Test username Twice', 'Test Status Twice', {
        from: mainAccount
      })
      .then(assert.fail)
      .catch(function(error) {
        assert(true);
      });
  });
});
