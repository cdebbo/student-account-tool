var app = angular.module('pwdtool', []);
app.controller('pwdtoolctrl', function ($scope, $http) {

    $scope.selected_user = "";
    $http.post('pwdtoolgetLoggedInUserName.ps1', null).then(function (data, status) {
      if (data.data.poshusername == "") {
        $scope.windows_user_name = "";
        //alert("User not in a valid group or general error");
      } else {
        $scope.windows_user_name = data.data.poshusername;
        //alert("retreived the user's name");
      }
    }, function (data, status) {
        $scope.windows_user_name = "";
        alert("Unable to retrieve user's account name.");
    });

    $scope.findStudent = function () {
        $scope.selected_user = "";
        if ($scope.student_name.length < 3) {
            alert("Please provide more characters in the student's name.");
            return;
        }
        var data = $.param({
            name: $scope.student_name
        });
        $http.post('pwdtoolfindStudent.ps1', data).then(function (data, status) {
            if (data.data.users.length == 0) {
                $scope.find_message = "No students found or you do not have staff permissions";
                $scope.users = null;
            } else {
                if (data.data.users instanceof Array) {
                    $scope.find_message = "Found " + data.data.users.length + " students.";
                    $scope.users = data.data.users;
                } else {
                    $scope.find_message = "Found 1 student.";
                    $scope.users = [data.data.users];
                }
            }
        }, function (data, status) {
            alert("Unable to find any students that match your query.");
        });
    }

    $scope.setSelectedStudent = function (user) {
//# added Dec 2
        $scope.selected_user_mail = user.mail
        $scope.selected_user_gafemail = user.gafemail;
        $scope.selected_user_gafeou = user.gafeou;
        $scope.selected_user_oen = user.employeenumber;
        $scope.selected_user_mwnumber = user.employeeid;
        $scope.selected_user_isdisabled = (!user.Enabled);
//#
        $scope.selected_user = user.DisplayName;
        $scope.selected_user_sam = user.samaccountname;
        $scope.selected_user_islockedout = (user.lockedOut != 0);
        $scope.unlock_account = false;
        $scope.student_password = "";
        $scope.disable_reason = "";
        $scope.current_student_password = "";
        //console.log($scope.selected_user);
    }

    $scope.resetStudent = function (action, teacher_password, student_password, change_at_next_logon, disable_reason) {
        var data = $.param({
            susername: $scope.selected_user_sam,
            spassword: student_password,
            tpassword: teacher_password,
            change_at_next_logon: change_at_next_logon,
            reason: disable_reason,
            action: action
        });
        //console.log(data);
        $scope.reset_status = "Sending Request";
        $http.post('pwdtoolresetAccount.ps1', data).then(function (data, status) {
            $scope.reset_status = data.data.reset_status;
        }, function (data, status) {
            alert("Unable to perform the operation.");
            $scope.reset_status = "Unexpected Error: Unable to complete this operation.";
        });
    }
    $scope.validateStudent = function (current_student_password) {
        var data = $.param({
            susername: $scope.selected_user_sam,
            spassword: current_student_password
        });
        //console.log(data);
        $scope.validation_status = "Validating";
        $http.post('pwdtoolvalidatePassword.ps1', data).then(function (data, status) {
            $scope.validation_status = data.data.validation_status;
        }, function (data, status) {
            alert("Unable to validate this account.");
            $scope.validation_status = "Unexpected Error: Unable to validate this account..";
        });
    }
})