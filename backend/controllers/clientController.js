const Client = require('../models/client');

exports.getAllClients = async (req, res) => {
  try {
    const allClients = await Client.find({})
      .populate({
        path: 'user',
        select: 'fullName userId email phone'
      })
      .select('user tripsnumber profileImageUrl totalSpending isAvailable')
      .lean();
    res.status(200).json(allClients);
  } catch (error) {
    console.error("Error fetching all clients:", error);
    res.status(500).json({ message: "حدث خطأ أثناء جلب جميع العملاء", error: error.message });
  }
};

exports.getClientById = async (req, res) => {
  try {
    const clientId = req.params.id;

    const client = await Client.findOne({ clientUserId: clientId })
      .populate({
        path: 'user',
        select: 'fullName userId email phone profilePhoto'
      })
      .select('user tripsnumber profileImageUrl totalSpending isActive')
      .lean();

    if (!client) {
      return res.status(404).json({ message: "لم يتم العثور على العميل" });
    }

    const response = {
      ...client,
      user: {
        ...client.user,
        profilePhoto: client.user.profilePhoto
          ? `${req.protocol}://${req.get('host')}/uploads/${client.user.profilePhoto}`
          : null
      }
    };

    res.status(200).json(response);
  } catch (error) {
    console.error("Error fetching client by ID:", error);
    res.status(500).json({ 
      message: "حدث خطأ أثناء جلب بيانات العميل",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

exports.updateAvailability = async (req, res) => {
  try {
    const { id } = req.params;
    const { isAvailable } = req.body;

    const updatedClient = await Client.findOneAndUpdate(
      { clientUserId: id },
      { isAvailable },
      { new: true }
    );

    if (!updatedClient) {
      return res.status(404).json({ message: 'Client not found' });
    }
    res.status(200).json(updatedClient);
  } catch (error) {
    console.error("Error updating client status:", error);
    res.status(500).json({ message: error.message });
  }
};

exports.updateClientProfileImage = async (req, res) => {
    try {
      const { id } = req.params;
      const { profileImageUrl } = req.body;
  
      const updatedClient = await Client.findOneAndUpdate(
        { clientUserId: id },
        { profileImageUrl },
        { new: true }
      );
  
      if (!updatedClient) {
        return res.status(404).json({ message: 'Client not found' });
      }
  
      res.status(200).json(updatedClient);
    } catch (error) {
      console.error("Error updating client profile image:", error);
      res.status(500).json({ message: error.message });
    }
  };
  