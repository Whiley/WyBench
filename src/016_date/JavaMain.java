public class MyDate {
  private int day, month, year; // 1 <= day <= 31 and 1 <= month <= 12

  public MyDate(int day, int month, int year) {
   this.day = day;
   this.month = month;
   this.year = year;

   // check invariantS hold
   if(day <= 0 || month < 0) { throw new IllegalArgumentException("Invalid Month"); } 

   else if((month==4 || month==6 || month==9 || month==11) && day > 30) {
    throw new RuntimeException("Cannot construct invalid Date!");

   } else if(month == 2 && (day>29 || (day>28 && !(year%4==0 &&
       (year%100 != 0 || year%400==0))))) {
    throw new RuntimeException("Cannot construct invalid Date!");

   } else if(day > 31 || month > 12) {
    throw new RuntimeException("Cannot construct invalid Date!");   
   }
 }

 public int day() { return day; }
 public int month() { return day; }
 public int year() { return day; }
}

