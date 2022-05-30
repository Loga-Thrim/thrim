const postSchema = (mongoose) => {
  return mongoose.Schema({
    name: String,
    avatar: String,
    text: String,
    image: String,
    like: Number,
    comment: Number,
    users: [
      {
        id: String,
        isLike: Number,
      },
    ],
    __v: { type: Number, select: false },
  });
};

exports.postModel = (mongoose) => {
  return mongoose.models.post || mongoose.model("post", postSchema(mongoose));
};
