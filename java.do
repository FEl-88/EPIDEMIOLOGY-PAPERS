java: // calling java using stata 17.0  
/* Java class begins here */
 import java.math.BigInteger;
 import com.stata.sfi.*;
 public class MyClass {
 /* Define the static method with the correct signature */
 public static int sub_string_vals(String[] args) {
 long nobs1 = Data.getObsParsedIn1() ;
 long nobs2 = Data.getObsParsedIn2() ;
 BigInteger b1, b2 ;
 if (Data.getParsedVarCount() != 2) {
 SFIToolkit.error("Exactly two variables must be specified\n") ;
 return(198) ;
 }
 if (args.length != 1) {
 SFIToolkit.error("New variable name not specified\n") ;
 return(198) ;
 }
 if (Data.addVarStr(args[0], 10)!=0) {
 SFIToolkit.errorln("Unable to create new variable " + args[0]) ;
 return(198) ;
 }
 // get the real indexes of the varlist
 int mapv1 = Data.mapParsedVarIndex(1) ;
 int mapv2 = Data.mapParsedVarIndex(2) ;
 int resv = Data.getVarIndex(args[0]) ;
 if (!Data.isVarTypeStr(mapv1) || !Data.isVarTypeStr(mapv2)) {
 SFIToolkit.error("Both variables must be strings\n") ;
 return(198) ;
 }
 for(long obs=nobs1; obs<=nobs2; obs++) {
 // Loop over the observations
  if (!Data.isParsedIfTrue(obs)) continue ;
 // skip any observations omitted from an [if] condition
 try {
 b1 = new BigInteger(Data.getStr(mapv1, obs)) ;
 b2 = new BigInteger(Data.getStr(mapv2, obs)) ;
 Data.storeStr(resv, obs, b1.subtract(b2).toString()) ;
 }
 catch (NumberFormatException e) { }
 }
 return(0) ;
 }
 }
 /* Java class ends here */
 end
