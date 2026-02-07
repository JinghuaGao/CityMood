// 响应工具函数

const success = (res, data, message = 'success', code = 200) => {
  res.status(code).json({
    code,
    message,
    data,
    timestamp: new Date().toISOString()
  });
};

const error = (res, message, code = 400, details = null) => {
  const response = {
    code,
    message,
    timestamp: new Date().toISOString()
  };
  if (details) {
    response.details = details;
  }
  res.status(code).json(response);
};

// 分页响应
const paginated = (res, data, pagination) => {
  res.status(200).json({
    code: 200,
    message: 'success',
    data,
    pagination: {
      page: pagination.page,
      pageSize: pagination.pageSize,
      total: pagination.total,
      totalPages: Math.ceil(pagination.total / pagination.pageSize)
    },
    timestamp: new Date().toISOString()
  });
};

module.exports = {
  success,
  error,
  paginated
};
