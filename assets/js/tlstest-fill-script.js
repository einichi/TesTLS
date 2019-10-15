$('#hostname').on('change keyup', function() {
    changeScriptVars("HOST", $('#hostname').val());
});
$('#email').on('change keyup', function() {
    changeScriptVars("EMAIL", $('#email').val());
});
$('#le-agree').on('change', function() {
    if ($('#le-agree').is(':checked')) {
        changeScriptVars("AGREE", "true");
    }
    else {
        changeScriptVars("AGREE", "false");
    }
});
$('#cipher-boxes input[type=checkbox]').on('change', function() {
    updateProtocolCiphers();
});

function changeScriptVars(varname, varval) {
    var i=0;
    $('#scriptgen').children('span').each(function () {
        if ($(this).text() == varname) {
            $('#scriptgen').children('span').eq(i+2).text('"'+varval+'"');
            return 0;
        }
        i++;
    });
}

function updateProtocolCiphers() {
    var ciphers = [];
    var tls13 = false;
    var tls12 = false;
    var tls11 = false;
    var tls10 = false;
    $('#cipher-boxes input[type=checkbox]').each(function () {
        if ($(this).is(':checked')) {
            ciphers.push($(this).val());
            if ($(this).attr('id').includes("tls1_3")) {
                tls13 = true;
            }
            else if ($(this).attr('id').includes("tls1_2")) {
                tls12 = true;
            }
            else if ($(this).attr('id').includes("tls1_1")) {
                tls11 = true;
            }
            else if ($(this).attr('id').includes("tls1_0")) {
                tls10 = true;
            }
        }
    });
    var protocolString = "";
    if (tls13) {
        protocolString += "+TLSv1.3 ";
    }
    if (tls12) {
        protocolString += "+TLSv1.2 ";
    }
    if (tls11) {
        protocolString += "+TLSv1.1 ";
    }
    if (tls10) {
        protocolString += "+TLSv1 ";
    }
    protocolString = protocolString.slice(0,-1);
    var uniqueCiphers = [...new Set(ciphers)];
    var cipherString = "";
    uniqueCiphers.forEach(function(cipher){
        cipherString += cipher+":";
    });
    cipherString = cipherString.slice(0,-1);
    changeScriptVars("PROTOCOLS", protocolString);
    changeScriptVars("CIPHERS", cipherString);
}