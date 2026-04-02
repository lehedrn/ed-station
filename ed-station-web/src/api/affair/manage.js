/**
 * 事项管理 API 接口封装
 * @module api/affair/manage
 */
import request from '@/axios';

/**
 * 分页查询事项列表
 * @param {number} current - 当前页码
 * @param {number} size - 每页条数
 * @param {object} params - 查询条件
 * @returns {Promise}
 */
export const getList = (current, size, params) => {
  return request({
    url: '/blade-affair/affair/list',
    method: 'get',
    params: { ...params, current, size },
    cryptoToken: false,
    cryptoData: false,
  });
};

/**
 * 详情查询
 * @param {string|number} id - 事项 ID
 * @returns {Promise}
 */
export const getDetail = (id) => {
  return request({
    url: '/blade-affair/affair/detail',
    method: 'get',
    params: { id },
    cryptoToken: false,
    cryptoData: false,
  });
};

/**
 * 事项新增
 * @param {object} data - 事项数据
 * @returns {Promise}
 */
export const save = (data) => {
  return request({
    url: '/blade-affair/affair/save',
    method: 'post',
    data,
    cryptoToken: false,
    cryptoData: false,
  });
};

/**
 * 事项修改
 * @param {object} data - 事项数据（包含 id）
 * @returns {Promise}
 */
export const update = (data) => {
  return request({
    url: '/blade-affair/affair/update',
    method: 'post',
    data,
    cryptoToken: false,
    cryptoData: false,
  });
};

/**
 * 事项删除（支持批量）
 * @param {string} ids - 事项 ID（逗号分隔）
 * @returns {Promise}
 */
export const remove = (ids) => {
  return request({
    url: '/blade-affair/affair/remove',
    method: 'post',
    params: { ids },
    cryptoToken: false,
    cryptoData: false,
  });
};

/**
 * 事项发布
 * @param {string|number} id - 事项 ID
 * @returns {Promise}
 */
export const publish = (id) => {
  return request({
    url: '/blade-affair/affair/publish',
    method: 'post',
    params: { id },
    cryptoToken: false,
    cryptoData: false,
  });
};

/**
 * 事项下架
 * @param {string|number} id - 事项 ID
 * @returns {Promise}
 */
export const unpublish = (id) => {
  return request({
    url: '/blade-affair/affair/unpublish',
    method: 'post',
    params: { id },
    cryptoToken: false,
    cryptoData: false,
  });
};

/**
 * 文件上传
 * @param {File} file - 文件对象
 * @returns {Promise}
 */
export const uploadFile = (file) => {
  const formData = new FormData();
  formData.append('file', file);
  return request({
    url: '/blade-resource/attach/upload',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    cryptoToken: false,
    cryptoData: false,
  });
};
