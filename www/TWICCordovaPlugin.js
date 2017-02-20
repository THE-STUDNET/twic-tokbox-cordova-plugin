var exec = require('cordova/exec');

exports.configure = function(arg0, success, error) {
    exec(success, error, "TWICCordovaPlugin", "configure", [arg0]);
};

exports.show = function(arg0, success, error) {
    exec(success, error, "TWICCordovaPlugin", "show", [arg0]);
};
