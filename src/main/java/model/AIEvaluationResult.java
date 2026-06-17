package model;

import com.google.gson.annotations.SerializedName;

public class AIEvaluationResult {

    @SerializedName("ai_star")
    private int aiStar;

    private String summary;
    private String strengths;
    private String weaknesses;

    @SerializedName("missing_requirements")
    private String missingRequirements;

    private String evidence;

    private int convertedPoint;
    private String rawResponse;

    public int getAiStar() {
        return aiStar;
    }

    public void setAiStar(int aiStar) {
        this.aiStar = aiStar;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getStrengths() {
        return strengths;
    }

    public void setStrengths(String strengths) {
        this.strengths = strengths;
    }

    public String getWeaknesses() {
        return weaknesses;
    }

    public void setWeaknesses(String weaknesses) {
        this.weaknesses = weaknesses;
    }

    public String getMissingRequirements() {
        return missingRequirements;
    }

    public void setMissingRequirements(String missingRequirements) {
        this.missingRequirements = missingRequirements;
    }

    public String getEvidence() {
        return evidence;
    }

    public void setEvidence(String evidence) {
        this.evidence = evidence;
    }

    public int getConvertedPoint() {
        return convertedPoint;
    }

    public void setConvertedPoint(int convertedPoint) {
        this.convertedPoint = convertedPoint;
    }

    public String getRawResponse() {
        return rawResponse;
    }

    public void setRawResponse(String rawResponse) {
        this.rawResponse = rawResponse;
    }
}