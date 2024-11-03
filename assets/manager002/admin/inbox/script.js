document.getElementById('closeButton').addEventListener('click', hideMessage);

function showMessage() {
    document.getElementById('inboxMessage').style.opacity = 1;
}

function hideMessage() {
    document.getElementById('inboxMessage').style.opacity = 0;
}