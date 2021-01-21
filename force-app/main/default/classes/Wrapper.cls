public class Wrapper {
    public class Account {
        public Id account_id               {get;set;}
        public String account_name         {get;set;}
        public String account_type         {get;set;}
        public String account_phone        {get;set;}
    }

    public class Opportunity {
        public Id opp_id               {get;set;}
        public String opp_name         {get;set;}
        public String opp_type         {get;set;}
        public String opp_stageName    {get;set;}
        public Date opp_closeDate      {get;set;}
    }

    public class User {
        public Id user_id               {get;set;}
        public String user_username     {get;set;}
        public String user_lastName     {get;set;}
        public String user_email        {get;set;}
    }

    public class ResponseResource {
        //'{ "success": true, "message":"登録に成功しました", "code":200 }
        public Boolean success;
        public String  message;
        public Integer code;
    }

    public class CustomHttpResponse {
        public HttpResponse httpResponse    {get;set;}
        public Boolean isSynced             {get;set;}
        public Set<Id> ids                  {get;set;}
        public List<sObject> sObjs          {get;set;}
    }
}