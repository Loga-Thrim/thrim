const { postModel } = require("../model/model");

exports.get = (req, res, mongoose) => {
  const { userId } = req.params;
  postModel(mongoose).find({}, (err, data) => {
    if (err) {
      res.json({ status: "error", message: err });
    } else {
      data.map(e => {
        e.users = e.users.filter(f => f.id === userId);
        return e;
      });
      res.json({ status: "success", data });
    }
  });
};

exports.post = (req, res, mongoose) => {
  postModel(mongoose).create([
    {
      name: "GFD",
      avatar: "assets/images/myself3.jpg",
      text: "To day i send request to open workspace https://facebook.com/",
      image: "",
      like: 28,
      comment: 2,
      users: [],
    },
    {
      name: "Loga Thrim",
      avatar: "assets/images/myself.jpg",
      text: "The man who knew the infinity visite in https://google.com/ .",
      image: "assets/images/content-img.jpg",
      like: 480,
      comment: 25,
      users: [],
    },
    {
      name: "Aphinant Chatchanthuek",
      avatar: "assets/images/myself2.jpg",
      text: "Happy Birthday Faker!!.",
      image: "assets/images/content-img2.png",
      like: 230,
      comment: 95,
      users: [],
    },
  ]);
  res.json({ status: "success" });
};

exports.isLike = (req, res, mongoose) => {
  const { newLike, oldLike, userId, postId } = req.body;

  let numberLikeUpdate = 0;
  if(newLike === 1 && oldLike === 0) numberLikeUpdate = 1;
  else if(newLike === -1 && oldLike === 0) numberLikeUpdate = -1;
  else if(newLike === 1 && oldLike === 1) numberLikeUpdate = -1;
  else if(newLike === -1 && oldLike === -1) numberLikeUpdate = 1;
  else if(newLike === -1 && oldLike === 1) numberLikeUpdate = -2;
  else if(newLike === 1 && oldLike === -1) numberLikeUpdate = 2;

  const dataLikeUpdate = { $inc: { like: numberLikeUpdate  } }

  const isLikeUpdate = [
    {
      $set: {
        users: {
          $cond: {
            if: { $in: [userId, "$users.id"] },
            then: {
              $map: {
                input: "$users",
                as: "user",
                in: {
                  id: "$$user.id",
                  isLike: newLike === oldLike ? 0 : newLike,
                },
              },
            },
            else: {
              $concatArrays: ["$users", [{ id: userId, isLike: newLike }]],
            },
          },
        },
      },
    },
  ];

  const _postModel = postModel(mongoose);

  _postModel.update(
    { _id: mongoose.Types.ObjectId(postId) },
    dataLikeUpdate,
    (err, doc) => {
      if (err) return res.json({ status: "error", message: err });

      _postModel.update(
        { _id: mongoose.Types.ObjectId(postId) },
        isLikeUpdate,
        function (err, doc) {
          if (err) return res.json({ status: "error", message: err });
          return res.json({ status: "success" });
        }
      );
    }
  );
};
