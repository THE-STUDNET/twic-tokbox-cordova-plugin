var exec = require('cordova/exec');

exports.launchHangout = function(arg0, success, error) {
    exec(success, error, "TWICCordovaPlugin", "launchHangout", [arg0]);
};
