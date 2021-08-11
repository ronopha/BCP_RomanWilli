const Migrations = artifacts.require("Migrations");

contract('Migration Test',(accounts) => {
  
 
  
   
    it("Migration Test", async() =>{        
        mig = await Migrations.deployed();
        console.log(mig.address);
        //assert(bcp.address != '');


      });
    
  
      
  }); // end of testing file