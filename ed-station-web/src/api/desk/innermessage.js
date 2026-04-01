import request from '@/axios';

export const getList = (current, size, params) => {
  return request({
    url: '/blade-desk/innermessage/list',
    method: 'get',
    params: {
      ...params,
      current,
      size,
    },
    cryptoToken: false,
    cryptoData: false,
  });
};

export const remove = ids => {
  return request({
    url: '/blade-desk/innermessage/remove',
    method: 'post',
    params: {
      ids,
    },
    cryptoToken: false,
    cryptoData: false,
  });
};

export const add = row => {
  return request({
    url: '/blade-desk/innermessage/submit',
    method: 'post',
    data: row,
    cryptoToken: false,
    cryptoData: false,
  });
};

export const update = row => {
  return request({
    url: '/blade-desk/innermessage/submit',
    method: 'post',
    data: row,
    cryptoToken: false,
    cryptoData: false,
  });
};

export const getDetail = id => {
  return request({
    url: '/blade-desk/innermessage/detail',
    method: 'get',
    params: {
      id,
    },
    cryptoToken: false,
    cryptoData: false,
  });
};
