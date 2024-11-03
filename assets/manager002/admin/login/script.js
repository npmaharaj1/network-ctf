if (localStorage.getItem('verified') == 1) {
    window.location.replace("../");
}


function validateLogin() {
    var username = document.getElementById('username').value;
    var password = document.getElementById('password').value;

    if (username == "admin" && password == "d13efa55c649ca10b54bc04de9b13ed7") {
        localStorage.setItem('verified', 1);
    } else {
        document.getElementById('LoginError').style.opacity = 1;
    }
}