package service;

public class ScoringService {

    private static final double WEIGHT_AI = 0.4;
    private static final double WEIGHT_PEER = 0.3;
    private static final double WEIGHT_LEADER = 0.3;

    public int convertStarToPoint(int star) {
        switch (star) {
            case 5:
                return 20;
            case 4:
                return 10;
            case 3:
                return 0;
            case 2:
                return -10;
            case 1:
                return -20;
            default:
                return 0;
        }
    }

    public int roundStar(double averageStar) {
        int rounded = (int) Math.round(averageStar);

        if (rounded < 1) {
            return 1;
        }

        if (rounded > 5) {
            return 5;
        }

        return rounded;
    }

    public double calculateStockChange(int bestAiStar, double avgPeerStar, int leaderStar) {
        int aiPoint = convertStarToPoint(bestAiStar);
        int peerPoint = convertStarToPoint(roundStar(avgPeerStar));
        int leaderPoint = convertStarToPoint(leaderStar);

        double result = aiPoint * WEIGHT_AI
                      + peerPoint * WEIGHT_PEER
                      + leaderPoint * WEIGHT_LEADER;

        return Math.round(result);
    }

    public double calculateFinalScore(double memberStockPrice, double groupAverageStockPrice, double teacherScore) {
        if (groupAverageStockPrice <= 0) {
            return teacherScore;
        }

        double finalScore = (memberStockPrice / groupAverageStockPrice) * teacherScore;

        if (finalScore > 10) {
            finalScore = 10;
        }

        if (finalScore < 0) {
            finalScore = 0;
        }

        return Math.round(finalScore * 10.0) / 10.0;
    }
}