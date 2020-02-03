<template>
  <div>
    <h1 class="title">Register</h1>

    <div class="row">
      <div class="col-md-3">
        <div class="form-group">
          <label for="description">Name</label>
          <input class="form-control" placeholder="Enter your name" type="text" v-model="userName" />
        </div>

        <div class="form-group">
          <label for="description">Status</label>
          <input
            class="form-control"
            placeholder="Enter your status"
            type="text"
            v-model="userStatus"
          />
        </div>

        <button class="btn btn-primary" :disabled="disableSubmit" @click="performSubmit">Register</button>
        <strong v-show="submitting">Submitting...</strong>

        <strong class="text-danger"></strong>

        <div v-show="errorStr" class="alert alert-danger mt-3" role="alert">
          {{ errorStr }}
          <br />
          <small>Check the browser console for more details.</small>
        </div>

        <div v-show="successMessage" class="alert alert-success mt-3" role="alert">
          <strong>You've been registerd!</strong>
          <br />You will be redirected to the profile page
          <strong>once the block will be mined!</strong>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// importing common function
import mixin from "../libs/mixinViews";

export default {
  mixins: [mixin],

  data() {
    return {
      userName: "",
      userStatus: "",
      submitting: false,
      successMessage: false,
      tmoConn: null,
      tmoReg: null,
      errorStr: null
    };
  },

  computed: {
    disableSubmit() {
      return (
        !this.userName.length ||
        !this.userStatus.length ||
        this.submitting ||
        !this.blockchainIsConnected()
      );
    }
  },

  created() {
    // it checks every 500ms if the user is registered until the connection is established
    this.redirectIfUserRegistered();
  },

  methods: {
    /**
     * Perform the registration of the user when the submit button is pressed.
     *
     * @return {void}
     */
    performSubmit() {
      this.submitting = true;
      this.errorStr = null;
      this.successMessage = false;

      window.bc
        .getMainAccount()
        .then(address => this.performUserRegistration(address));
    },

    /**
     * Show the form error.
     *
     * @param {object} err
     * @return {void}
     */
    showErrorMessage(err) {
      console.error(err);

      this.errorStr = null;

      if (err) this.errorStr = err.toString();

      if (!this.errorStr) this.errorStr = "Error occurred!";
    },

    /**
     * @param {string} address
     * @return {void}
     */
    performUserRegistration(address) {
      window.bc.contract().registerUser(
        this.userName,
        this.userStatus,
        {
          from: address,
          gas: 800000
        },
        (err, txHash) => {
          this.submitting = false;

          if (err) {
            this.showErrorMessage(err);
          } else {
            this.successMessage = true;

            Event.$emit("userregistered", txHash);

            this.redirectWhenBlockMined();
          }
        }
      );
    },

    /**
     * @return {void}
     */
    redirectIfUserRegistered() {
      this.tmoConn = setInterval(() => {
        // checking first the connection
        if (this.blockchainIsConnected()) {
          // stopping the interval
          clearInterval(this.tmoConn);

          // calling the smart contract
          this.isRegistered().then(res => {
            if (res) {
              // redirecting to the profile page
              this.$router.push("profile");
            }
          });
        }
      }, 500);
    },

    /**
     * @return {void}
     */
    redirectWhenBlockMined() {
      this.tmoReg = setInterval(() => {
        if (this.blockchainIsConnected()) {
          this.isRegistered()
            .then(res => {
              if (res) {
                // stopping the setInterval
                clearInterval(this.tmoReg);

                // redirecting the user to the profile page
                this.$router.push("profile");
              }
            })
            .catch(error => this.showErrorMessage(error));
        }
      }, 1000);
    }
  }
};
</script>
