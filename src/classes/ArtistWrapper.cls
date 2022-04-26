public with sharing class ArtistWrapper {

    @AuraEnabled public Artists artists;

    public class ExternalUrls {
        @AuraEnabled public String spotify;
    }

    public class Followers {
        @AuraEnabled public Object href;
        @AuraEnabled public Integer total;
    }

    public class Artists {
        @AuraEnabled public String href;
        @AuraEnabled public List<SingleArtistWrapper> items;
        @AuraEnabled public String next;
        @AuraEnabled public Integer offset;
        @AuraEnabled public String previous;
        @AuraEnabled public Integer total;
    }

}