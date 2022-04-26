public with sharing class TracksService {

    public static Track__c getTrackFromInside(String trackId) {

        List<Track__c> track = [SELECT Name,SpotifyId__c,Favorite__c,BlackList__c,Image__c FROM Track__c WHERE SpotifyId__c = :trackId AND CreatedBy.Id = :UserInfo.getUserId()];
        return track.isEmpty() ? new Track__c() : track[0];
    }

    public static Track__c addOrRemoveFav(String trackId) {
        List<Track__c> track = [SELECT Name,SpotifyId__c,Favorite__c,BlackList__c,Image__c FROM Track__c WHERE SpotifyId__c = :trackId AND CreatedBy.Id = :UserInfo.getUserId()];
        if (track.isEmpty()) {
            SingleTrackWrapper trackWrapper = ConnectSpotify.getTrack(trackId);
            Track__c newTrack = new Track__c(Name = trackWrapper.name, SpotifyId__c = trackId, Favorite__c = true, Image__c = trackWrapper.album.images[0].url);
            insert newTrack;
            return newTrack;
        } else {
            if (track[0].Favorite__c == true) {
                track[0].Favorite__c = false;
            } else {
                track[0].Favorite__c = true;
                track[0].BlackList__c = false;
            }
            update track;
            return track[0];
        }
    }

    public static Track__c addOrRemoveBlacklist(String trackId) {
        List<Track__c> track = [SELECT Name,SpotifyId__c,Favorite__c,BlackList__c,Image__c FROM Track__c WHERE SpotifyId__c = :trackId AND CreatedBy.Id = :UserInfo.getUserId()];
        if (track.isEmpty()) {
            SingleTrackWrapper trackWrapper = ConnectSpotify.getTrack(trackId);
            Track__c newTrack = new Track__c(Name = trackWrapper.name, SpotifyId__c = trackId, BlackList__c = true, Image__c = trackWrapper.album.images[0].url);
            insert newTrack;
            return newTrack;
        } else {
            if (track[0].BlackList__c == true) {
                track[0].BlackList__c = false;
            } else {
                track[0].BlackList__c = true;
                track[0].Favorite__c = false;
            }
            update track;
            return track[0];

        }
    }

    public static List<Track__c> getFavoriteTracks() {
        List<Track__c> tracks = [SELECT Name,SpotifyId__c,Favorite__c,BlackList__c,Image__c FROM Track__c WHERE Favorite__c = true AND CreatedBy.Id = :UserInfo.getUserId()];
        return tracks.isEmpty() ? new List<Track__c>() : tracks;
    }


    public static List<Track__c> getBlackListTracks() {
        List<Track__c> tracks = [SELECT Name,SpotifyId__c,Favorite__c,BlackList__c,Image__c FROM Track__c WHERE BlackList__c = true AND CreatedBy.Id = :UserInfo.getUserId()];
        return tracks.isEmpty() ? new List<Track__c>() : tracks;
    }

    public static Set<String> getBlackListTracksSpotifyId() {
        List<Track__c> tracks = [SELECT Name,SpotifyId__c,Image__c FROM Track__c WHERE BlackList__c = true AND CreatedBy.Id = :UserInfo.getUserId()];
        Set<String> trackBlackListIds = new Set<String>();
        for (Track__c track : tracks) {
            trackBlackListIds.add(track.SpotifyId__c);
        }
        return trackBlackListIds.isEmpty() ? new Set<String>() : trackBlackListIds;
    }

    public static List<Comment__c> addComment(String trackId, String content) {
        Comment__c newComment = new Comment__c(SpotifyId__c = trackId, Content__c = content, CreatedDate__c = Date.today(),Created_Date_Time__c = Datetime.now());
        insert newComment;
        List<Comment__c> comments = [SELECT Id,SpotifyId__c,Content__c,CreatedBy.Name,CreatedDate__c FROM Comment__c WHERE SpotifyId__c = :trackId ORDER BY Created_Date_Time__c DESC ];
        return comments;
    }

    public static List<Comment__c> getComments(String trackId) {
        List<Comment__c> comments = [SELECT Id,SpotifyId__c,Content__c,CreatedBy.Name,CreatedDate__c FROM Comment__c WHERE SpotifyId__c = :trackId ORDER BY Created_Date_Time__c DESC] ;
        return comments;
    }

    public static Decimal addNewRate(String trackId, Integer rate) {
        List<Rate__c> rates = [SELECT Id,SpotifyId__c,CreatedBy.Id FROM Rate__c WHERE SpotifyId__c = :trackId AND CreatedBy.Id = :UserInfo.getUserId()];
        if(rates.isEmpty()){
            Rate__c newRate = new Rate__c(SpotifyId__c=trackId, RateValue__c=rate);
            insert newRate;
        }else{
            rates[0].RateValue__c=rate;
            update rates;
        }
        return getTrackRate(trackId);
    }

    public static Decimal getTrackRate(String trackId) {
        Decimal amountTrackRates = [SELECT COUNT() FROM Rate__c WHERE SpotifyId__c = :trackId];
        if(amountTrackRates>0){
        List<AggregateResult> sumTrackRates = [SELECT SUM(RateValue__c)sumRates FROM Rate__c WHERE SpotifyId__c = :trackId];
        Decimal sumRateValues = (Decimal)sumTrackRates[0].get('sumRates');
        return sumRateValues/amountTrackRates;
        }else{
            return 0;
        }
    }

    public static Boolean isRate(String trackId) {
     return  [SELECT COUNT() FROM Rate__c WHERE SpotifyId__c = :trackId AND CreatedBy.Id = :UserInfo.getUserId()]==0;
    }

    public static Rate__c getUserRate(String trackId) {
        return  [SELECT ID,RateValue__c FROM Rate__c WHERE SpotifyId__c = :trackId AND CreatedBy.Id = :UserInfo.getUserId()];
    }
}