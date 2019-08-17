public const string describedDays[8] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};

public const string describedMonths[12] = {"January", "February", "March", "April", "May", "June", "July", 
                                      "August", "September", "October", "November", "December"};

public const string ordinalNumbers[31] = {"1st", "2nd", "3rd", "4th", "5th", "6th", "7th","8th","9th","10th",
                                        "11th", "12th","13th","14th","15th","16th","17th","18th","19th","20th",
                                      "21st", "22nd", "23rd", "24th", "25th","26th","27th","28th","29th","30th","31th"};

public const string periods[5] = {"minute", "hour", "day of month", "month", "day of week"};

public const string days[8] = {"sun", "mon", "tue", "wed", "thu", "fri", "sat", "sun"};

public const string months[12] = {"jan", "feb", "mar", "apr", "may", "jun",
                                                 "jul", "aug", "sep", "oct", "nov", "dec"};

public class util.Descriptor : GLib.Object{  
    string periodicity;
    string command;
    
    public Descriptor(string periodicity,string command){
        this.periodicity=periodicity;
        this.command=command;
    }
    
    //returns -1 for a bad periodicity and -2 for a bad command
    public string explain(){
        string periodExplanation=getPeriodExplanation();
        if(periodExplanation.has_prefix("-1")){
            return periodExplanation;
        }
        if(!isCommandValid()){
            return "-2";
        }
        return periodExplanation+" run "+command;
    }
    
    private string getPeriodExplanation() {
        if (periodicity == "@reboot"){
            return "Every time the computer reboots";
        }else if(periodicity == "@yearly" || periodicity == "@annually"){
            return "Every year (1st of January at 0:00)";
        }else if( periodicity == "@monthly"){
            return "Every month (1st of the month at 0:00)";
        }else if(periodicity == "@weekly"){
            return "Every week (Sunday at 0:00)";
        }else if(periodicity == "@daily" || periodicity == "@midnight"){
            return "Every day (at 0:00)";
        }else if(periodicity == "@hourly"){
            return "Every hour"; 
        }else{
            return readAllCronExpression();
        }
    }
    
    private string readAllCronExpression(){
        if(periodicity==null || !periodicity.contains(" "))
            return "-1 empty periodicity";
        string[] expressions=periodicity.split(" ");
        if(expressions.length!=5)
            return "-1 cron elements has not 5 elements";
        
        string result=readCronExpression(expressions[0],0);

        return result;
    }

    private string readCronExpression(string expressionSent,int periodPosition){
        string expression=expressionSent.down();
        string startWith="";
        if(periodPosition>1){
            startWith="on";
        }else{
            startWith="at";
        }
        if(expression=="*"){
            return startWith+" every "+periods[periodPosition];
        }else if(expression.has_prefix("*/")){
            string numberString=expression.replace("*/","");
            int number=int.parse(numberString);
            if(number==0)
                return "-1 "+number.to_string()+" is not a number";
            return startWith+" every "+ordinalNumbers[number-1]+" "+periods[periodPosition];
        }else if(expression.contains("-")){
            string[] numbersAsString=expression.split("-");
            if(numbersAsString.length!=2 || int.parse(numbersAsString[0])==0 || int.parse(numbersAsString[1])==0 || (int.parse(numbersAsString[0]) > int.parse(numbersAsString[1]))){
                return "-1 "+expression+" is not a valid interval";
            }
            return "from "+ordinalNumbers[int.parse(numbersAsString[0])-1]+" to "+ordinalNumbers[int.parse(numbersAsString[1])-1]+" "+periods[periodPosition];
        }else{
            string toReturn=startWith+" "+periods[periodPosition]+" ";
            string[] partsAsString=null;
            if(expression.contains(",")){
                partsAsString=expression.split(",");
            }else{
                partsAsString=new string[1];
                partsAsString[0]=expression;
            }
            int count=0;
            foreach (var part in partsAsString) {
                if(int.parse(part)==0 && part!="0" && part!="00" && part!="000" && part!="0000" && part!="00000" && part!="000000"){
                    if(periodPosition==2 || periodPosition==4){
                        //we can have days here
                        int i=0;
                        foreach (var day in days) {
                            if(day==part){
                                part=describedDays[i];
                                continue;
                            }
                            i++;
                        }
                        
                    }else if(periodPosition==3){
                        //we can have months here
                        int i=0;
                        foreach (var month in months) {
                            if(month==part){
                                part=describedMonths[i];
                                continue;
                            }
                            i++;
                        }
                    }
                    return "-1 "+expression+" is not a valid cron part";
                    
                }else{
                    int value =int.parse(part);
                    if(((value>59 || value<0) && periodPosition==0) || ((value>23 || value<0) && periodPosition==1) || ((value>31 || value<1) && periodPosition==2)
                        || ((value>12 || value<1) && periodPosition==3) || ((value>8 || value<1) && periodPosition==4)){
                            return "-1 "+expression+" contains data out of bound";
                        }
                    if(periodPosition==3){
                        part=describedDays[value];
                    }else if(periodPosition==4){
                        part=describedMonths[value];
                    }else{
                        toReturn+=value.to_string();
                    }
                }
                toReturn+=part;
                if(partsAsString.length!=1){
                    if(count==partsAsString.length-1){
                        toReturn+=" and ";
                    }else{
                        toReturn+=",";
                    }
                
                    count++;
                }
              
            }
            return toReturn;
        }/*else if(int.parse(expression)!=0){
            string toReturn=startWith+" "+periods[periodPosition]+" ";
            int value =int.parse(expression);
            if(((value>59 || value<0) && periodPosition==0) || ((value>23 || value<0) && periodPosition==1) || ((value>31 || value<1) && periodPosition==2)
                || ((value>12 || value<1) && periodPosition==3) || ((value>8 || value<1) && periodPosition==4)){
                    return "-1 "+expression+" contains data out of bound";
                }
            if(periodPosition==3){

            }else if(periodPosition==4){

            }else{
                toReturn+=value;
            }
        }*/
        
    }
    
     private bool isCommandValid() {
	    if (command==null || command==""){
		    return false;
	    }else{
	        return true;
	    }
    }
    
    public static int main(string[] args){
        Descriptor descriptor=new Descriptor("0 5 * * 1","/usr/bin/ls");
        print(descriptor.explain());
        return 0;
    }
}