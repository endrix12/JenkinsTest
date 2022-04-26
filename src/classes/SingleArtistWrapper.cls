public with sharing class SingleArtistWrapper extends SpotifyItemWrapper{

    @AuraEnabled public ExternalUrls external_urls;
    @AuraEnabled public Followers followers;
    @AuraEnabled public List<String> genres;
    @AuraEnabled public String href;
    @AuraEnabled public List<Image> images;
    @AuraEnabled public String name;
    @AuraEnabled public Integer popularity;
    @AuraEnabled public String uri;

    public class ExternalUrls{
        @AuraEnabled public String spotify;
    }

    public class Followers{
        @AuraEnabled public String href;
        @AuraEnabled public Integer total;
    }

    public class Image{
        @AuraEnabled public Integer height;
        @AuraEnabled public String url;
        @AuraEnabled public Integer width;
    }
}