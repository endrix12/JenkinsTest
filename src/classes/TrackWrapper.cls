public with sharing class TrackWrapper {
    @AuraEnabled
    public Tracks tracks;

    public class ExternalUrls{
        public String spotify;
    }

    public class Artist{
     @AuraEnabled   public ExternalUrls external_urls;
     @AuraEnabled   public String href;
     @AuraEnabled   public String id;
     @AuraEnabled   public String name;
     @AuraEnabled   public String type;
     @AuraEnabled   public String uri;
    }

    public class Image{
        public Integer height;
        @AuraEnabled
        public String url;
        public Integer width;
    }

    public class Album{
         @AuraEnabled  public String album_type;
         @AuraEnabled  public List<Artist> artists;
         @AuraEnabled  public List<String> available_markets;
         @AuraEnabled  public ExternalUrls external_urls;
         @AuraEnabled  public String href;
         @AuraEnabled  public String id;
         @AuraEnabled  public List<Image> images;
         @AuraEnabled  public String name;
         @AuraEnabled  public String release_date;
         @AuraEnabled  public String release_date_precision;
         @AuraEnabled  public Integer total_tracks;
         @AuraEnabled  public String type;
         @AuraEnabled  public String uri;
    }

    public class ExternalIds{
        public String isrc;
    }

    public class Item{

       @AuraEnabled   public Album album;
       @AuraEnabled   public List<Artist> artists;
       @AuraEnabled   public List<String> available_markets;
       @AuraEnabled   public Integer disc_number;
       @AuraEnabled   public Integer duration_ms;
       @AuraEnabled   public boolean explicit;
       @AuraEnabled   public ExternalIds external_ids;
       @AuraEnabled   public ExternalUrls external_urls;
       @AuraEnabled   public String href;
       @AuraEnabled   public String id;
       @AuraEnabled   public boolean is_local;
       @AuraEnabled   public String name;
       @AuraEnabled   public Integer popularity;
       @AuraEnabled   public String preview_url;
       @AuraEnabled   public Integer track_number;
       @AuraEnabled   public String type;
       @AuraEnabled   public String uri;
    }

    public class Tracks{
      @AuraEnabled   public String href;
      @AuraEnabled   public List<SingleTrackWrapper> items;
      @AuraEnabled   public String next;
      @AuraEnabled   public Integer offset;
      @AuraEnabled   public String previous;
      @AuraEnabled   public Integer total;
    }

}