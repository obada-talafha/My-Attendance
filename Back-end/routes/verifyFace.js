import axios from 'axios';

const verifyFace = async (req, res) => {
  const { image } = req.body;

  if (!image) {
    return res.status(400).json({
      success: false,
      message: "Image (base64) is required",
    });
  }

  try {
    const response = await axios.post('http://localhost:5000/verify-face', { image });

    if (response.data.status === 'success') {
      res.status(200).json({
        success: true,
        student_id: response.data.student_id,
        similarity: response.data.similarity,
      });
    } else {
      res.status(403).json({
        success: false,
        message: response.data.message || 'Face not recognized',
        highest_similarity: response.data.highest_similarity || 0,
      });
    }
  } catch (error) {
    console.error('Face recognition error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Face recognition service error',
    });
  }
};

export { verifyFace };
