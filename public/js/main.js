// check is array
function isArray(value) {
    return Object.prototype.toString.call(value) === '[object Array]';
}

// отображение спиннера и возврат ссылки на него
function create_spinner(id, position = 'before') {

    let inb = document.getElementById(id);
    if (!inb) return;

    let spinner = document.createElement("div");
    spinner.classList.add('spinner-border');
    spinner.classList.add('spinner-border-sm');
    spinner.setAttribute('role', 'status');
    spinner.innerHTML = '<span class="sr-only"></span>';

    if (position == 'after') {inb.append(spinner);} else {inb.prepend(spinner);}
    return(spinner);
}