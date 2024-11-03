var newDate = new Date().toDateString();

if (localStorage.getItem('verified') != 1) {
    window.location.replace('warning');
} 

document.getElementById('today1').innerHTML = newDate;
document.getElementById('today2').innerHTML = newDate;