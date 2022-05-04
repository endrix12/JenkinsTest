public with sharing class SpotifyController {

    @AuraEnabled
    public static ArtistWrapper getArtists(String artist) {
        ArtistWrapper artistWrapper = ConnectSpotify.searchArtistsCallout(artist);
        Set <String> blackListArtistsIds = ArtistsService.getBlackListArtistsSpotifyId();
        List<SingleArtistWrapper> singleArtistWrappers = artistWrapper.artists.items;
        List<SingleArtistWrapper> singleArtistWrappersFiltered = new List<SingleArtistWrapper>();
        for (SingleArtistWrapper singleArtistWrapper : singleArtistWrappers) {
            if (!blackListArtistsIds.contains(singleArtistWrapper.id)) {
                singleArtistWrappersFiltered.add(singleArtistWrapper);
            }
        }
        artistWrapper.artists.items = singleArtistWrappersFiltered;
        return artistWrapper;
    }

    @AuraEnabled
    public static ArtistWrapper getFoundArtist(String endpoint) {
        return ConnectSpotify.foundArtistCallout(endpoint);
    }

    @AuraEnabled
    public static TrackWrapper getFoundTrack(String endpoint) {
        return ConnectSpotify.foundTrackCallout(endpoint);
    }

    @AuraEnabled
    public static TrackWrapper getFoundLastTrack(String endpoint, Integer offset) {
        return ConnectSpotify.foundLastTrackCallout(endpoint, offset);
    }

    @AuraEnabled
    public static ArtistWrapper getFoundLastArtist(String endpoint, Integer offset) {
        return ConnectSpotify.foundLastArtistCallout(endpoint, offset);
    }

    @AuraEnabled
    public static TrackWrapper getTracks(String track) {
        TrackWrapper trackWrapper = ConnectSpotify.searchTracksCallout(track);
        Set <String> blackListTracksIds = TracksService.getBlackListTracksSpotifyId();
        List<SingleTrackWrapper> singleTrackWrappers = trackWrapper.tracks.items;
        List<SingleTrackWrapper> singleTrackWrappersFiltered = new List<SingleTrackWrapper>();
        for (SingleTrackWrapper singleTrackWrapper : singleTrackWrappers) {
            if (!blackListTracksIds.contains(singleTrackWrapper.id)) {
                singleTrackWrappersFiltered.add(singleTrackWrapper);
            }
        }
        trackWrapper.tracks.items = singleTrackWrappersFiltered;
        return trackWrapper;
    }

    @AuraEnabled
    public static SingleArtistTrackWrapper getArtistTracks(String artistId) {
        return ConnectSpotify.getArtistsTracks(artistId);
    }

    @AuraEnabled
    public static SingleTrackWrapper getTrackById(String trackId) {
        return ConnectSpotify.getTrack(trackId);
    }

    @AuraEnabled
    public static SingleArtistWrapper getArtistById(String artistId) {
        return ConnectSpotify.getArtist(artistId);
    }

    @AuraEnabled
    public static Artist__c getArtistFromInsideDb(String artistId) {
        return ArtistsService.getArtistFromInside(artistId);
    }

    @AuraEnabled
    public static Artist__c addOrRemoveFavorites(String artistId) {
        return ArtistsService.addOrRemoveFav(artistId);
    }

    @AuraEnabled
    public static Artist__c addOrRemoveBlackList(String artistId) {
        return ArtistsService.addOrRemoveBlacklist(artistId);
    }

    @AuraEnabled
    public static Track__c getTrackFromInsideDb(String trackId) {
        return TracksService.getTrackFromInside(trackId);
    }

    @AuraEnabled
    public static Track__c addOrRemoveTrackFavorites(String trackId) {
        return TracksService.addOrRemoveFav(trackId);
    }

    @AuraEnabled
    public static Track__c addOrRemoveTrackBlackList(String trackId) {
        return TracksService.addOrRemoveBlacklist(trackId);
    }


    @AuraEnabled
    public static List<Artist__c> getSaveFavoriteArtists() {
        return ArtistsService.getFavoriteArtists();
    }

    @AuraEnabled
    public static List<Artist__c> getSaveBlackListArtists() {
        return ArtistsService.getBlackListArtists();
    }

    @AuraEnabled
    public static List<Track__c> getSaveFavoriteTracks() {
        return TracksService.getFavoriteTracks();
    }

    @AuraEnabled
    public static List<Track__c> getSaveBlackListTracks() {
        return TracksService.getBlackListTracks();
    }

    @AuraEnabled
    public static List<Comment__c> addNewComment(String trackId, String content) {
        return TracksService.addComment(trackId, content);
    }

    @AuraEnabled
    public static List<Comment__c> addComment(String trackId, String content) {
        return TracksService.addCommentToProduct(trackId, content);
    }
    @AuraEnabled
    public static Comment__c getComment(String trackId) {
        return TracksService.getUserComment(trackId);
    }
      

    @AuraEnabled
    public static List<Comment__c> getCommentsById(String trackId) {
        return TracksService.getComments(trackId);
    }



    @AuraEnabled
    public static List<Rate__c> getRatesById(String trackId) {
        return TracksService.getRates(trackId);
    }

    @AuraEnabled
    public static Decimal addRate(String trackId, String rate) {
        return TracksService.addNewRate(trackId, Integer.valueOf(rate));
    }

    @AuraEnabled
    public static Decimal getTrackRateById(String trackId) {
        return TracksService.getTrackRate(trackId);
    }

    @AuraEnabled
    public static Boolean isRateByUser(String trackId) {
        return TracksService.isRate(trackId);
    }

    @AuraEnabled
    public static Rate__c getThisUserRate(String trackId) {
        return TracksService.getUserRate(trackId);
    }

    @AuraEnabled
    public static Rate__c getUserRateToProduct(String trackId, String userId) {
        return [SELECT Id,SpotifyId__c,RateValue__c,CreatedBy.Id FROM Rate__c WHERE SpotifyId__c = :trackId AND CreatedBy.Id = :userId];
    }
}