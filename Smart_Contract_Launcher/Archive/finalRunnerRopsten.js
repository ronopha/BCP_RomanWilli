var daten = require('./deployRopstenRegistration.js');
//var daten1 = require('./deployRopstenCommitment.js');


async function f() {
  
  console.log(typeof(daten.RopstenRegistrationAddresse))
  console.log(typeof(daten.RopstenCommitmentAddresse))

  a = await daten.RopstenRegistrationAddresse();
 
  console.log(a)
  return
 
  b = await daten.RopstenCommitmentAddresse(a);


  console.log(a);
  console.log(b);


}

f();








