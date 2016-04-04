'use strict';

var express = require('express');
var app = express();

app.use('/stackwhack/', express.static('app'));
app.listen(9071);
