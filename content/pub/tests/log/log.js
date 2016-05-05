
function Log() {

    var logElement = document.createElement("div");
    logElement.className = "log";

    this.getElement = function() {
        return logElement;
    };

    this.log = function() {

        var entry = document.createElement("div");
        entry.className = "entry";

        for (var i=0; i<arguments.length; i++) {

            var value = document.createElement("span");
            value.className = "value";

            value.textContent = arguments[i];
            entry.appendChild(value);
            entry.innerHTML += ' ';

        }

        logElement.appendChild(entry);

    };

}

