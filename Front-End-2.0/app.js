var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

const { encrypt } = require('eth-sig-util');
const ethers = require('ethers');

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

///
const bodyParser = require('body-parser');

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: true }));

// parse application/json
app.use(bodyParser.json());

app.post('/encrypt', function(req, res) {
  const {message, publickey} = req.body;
  if (publickey != "" && message != ""){
    var encryptedMessage = encryptMessage(publickey, message);
    res.send(encryptedMessage);
  }
});

app.get("/transactionhistory", (req, res) => {
  res.render("transactionhistory", { title: 'Transaction History'});
});

app.get("/mytransactions", (req, res) => {
  res.render("mytransactions", { title: 'My Transactions'});
});

app.get("/profile", (req, res) => {
  res.render("profile", { title: 'Profile: ' + req.query.user});
});

app.get("/transactiondetail", (req, res) => {
  res.render("transactiondetail", { title: 'Transaction Detail'});
});

app.get("/createtransaction", (req, res) => {
  res.render("createtransaction", { title: 'Create Transaction'});
});

app.get("/myaccount", (req, res) => {
  res.render("myaccount", { title: 'My Account'});
});

app.get("/reputations", (req, res) => {
  res.render("reputations", { title: 'Reputations'});
});

app.get("/users", (req, res) => {
  res.render("users", { title: 'Users'});
});

app.get("/", (req, res) => {
  res.render("transactionhistory", { title: 'Transaction History'});
});

function encryptMessage(publickey, message){
  var encryptedMessage = stringifiableToHex(
    encrypt(
      publickey,
      { data: message },
      'x25519-xsalsa20-poly1305',
    ),
  );
  return encryptedMessage
  
}
function stringifiableToHex(value) {
  return ethers.utils.hexlify(Buffer.from(JSON.stringify(value)));
}

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

//app.use('/', indexRouter);
//app.use('/users', usersRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;