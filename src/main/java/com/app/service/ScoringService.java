package com.app.service;

public class ScoringService {

    // --- CÁC HẰNG SỐ TRỌNG SỐ ---
    private static final double WEIGHT_PEER = 0.3;
    private static final double WEIGHT_LEADER = 0.3;
    private static final double WEIGHT_AI = 0.4;

    /**
     * THUẬT TOÁN 1: Tính điểm hiệu suất cá nhân (30-30-40)
     */
    public double calculateFinalScore(double peerScore, double leaderScore, double aiScore) {
        
        // Tính điểm thô
        double rawScore = (peerScore * WEIGHT_PEER) + 
                          (leaderScore * WEIGHT_LEADER) + 
                          (aiScore * WEIGHT_AI);
        
        // Làm tròn theo bậc 0.5 (Ví dụ: 7.3 -> 7.5; 7.1 -> 7.0)
        return Math.round(rawScore * 2.0) / 2.0;
    }

    /**
     * THUẬT TOÁN 2: Phân phối điểm Giảng viên cho Nhóm (Neo điểm & Bù trừ độ lệch)
     * @param teacherScore Điểm do giảng viên chấm cho cả nhóm
     * @param internalScores Mảng điểm nội bộ của các thành viên (Đã tính từ Thuật toán 1)
     * @return Mảng điểm chính thức cuối cùng của từng người
     */
    public double[] distributeByDeviation(double teacherScore, double[] internalScores) {
        int n = internalScores.length;
        double[] finalScores = new double[n];
        
        // 1. Tính trung bình điểm nội bộ của cả nhóm
        double sumInternal = 0;
        for (double s : internalScores) {
            sumInternal += s;
        }
        double avgInternal = sumInternal / n;
        
        double overflowPool = 0;
        int notCappedCount = 0;
        
        // 2. Tính điểm dựa trên độ lệch (Delta) so với trung bình
        for (int i = 0; i < n; i++) {
            double delta = internalScores[i] - avgInternal; // Ai giỏi hơn mặt bằng chung sẽ có delta dương
            finalScores[i] = teacherScore + delta;          // Cộng độ lệch vào điểm Gốc của Giảng viên
            
            // 3. Cắt ngọn nếu điểm vượt quá 10.0
            if (finalScores[i] > 10.0) {
                overflowPool += (finalScores[i] - 10.0);    // Đưa điểm thừa vào quỹ chung
                finalScores[i] = 10.0;                      // Chốt cứng ở 10.0
            } else {
                notCappedCount++;
            }
        }
        
        // 4. Chia lại quỹ điểm thừa cho những người chưa đạt 10.0
        if (overflowPool > 0 && notCappedCount > 0) {
            double bonus = overflowPool / notCappedCount;
            for (int i = 0; i < n; i++) {
                if (finalScores[i] < 10.0) {
                    finalScores[i] += bonus;
                    // Đảm bảo sau khi cộng bonus vẫn không vượt 10
                    if (finalScores[i] > 10.0) {
                        finalScores[i] = 10.0; 
                    }
                }
            }
        }
        
        // 5. Làm tròn toàn bộ mảng kết quả theo bậc 0.5
        for (int i = 0; i < n; i++) {
            finalScores[i] = Math.round(finalScores[i] * 2.0) / 2.0;
        }
        
        return finalScores;
    }
}