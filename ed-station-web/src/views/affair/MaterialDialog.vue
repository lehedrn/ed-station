<template>
  <el-dialog
    v-model="dialogVisible"
    :title="title"
    width="800px"
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <el-form
      ref="materialFormRef"
      :model="materialForm"
      :rules="materialRules"
      label-width="100px"
    >
      <el-form-item label="材料名称" prop="materialName">
        <el-input
          v-model="materialForm.materialName"
          placeholder="请输入材料名称"
          maxlength="200"
          show-word-limit
        />
      </el-form-item>
      <el-form-item label="材料类型" prop="materialType">
        <el-select
          v-model="materialForm.materialType"
          placeholder="请选择材料类型"
          style="width: 100%"
        >
          <el-option
            v-for="item in materialTypeOptions"
            :key="item.dictKey"
            :label="item.dictValue"
            :value="item.dictKey"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="份数要求" prop="materialCopies">
        <el-input-number
          v-model="materialForm.materialCopies"
          :min="1"
          :max="99"
          placeholder="请输入份数"
        />
      </el-form-item>
      <el-form-item label="材料说明" prop="materialRemark">
        <el-input
          v-model="materialForm.materialRemark"
          type="textarea"
          :rows="3"
          placeholder="请输入材料说明"
          maxlength="500"
          show-word-limit
        />
      </el-form-item>
      <el-form-item label="附件文件" prop="attachId">
        <el-upload
          ref="uploadRef"
          :action="uploadUrl"
          :headers="uploadHeaders"
          :before-upload="beforeUpload"
          :on-success="handleUploadSuccess"
          :on-error="handleUploadError"
          :file-list="fileList"
          :limit="1"
          :accept="acceptFileTypes"
          class="material-upload"
        >
          <el-button type="primary">选择文件</el-button>
          <template #tip>
            <div class="el-upload__tip">
              支持 pdf/doc/docx/jpg/png 格式，大小不超过 10MB
            </div>
          </template>
        </el-upload>
      </el-form-item>
      <el-form-item
        v-if="materialForm.attach && (materialForm.attach.originalName || materialForm.attach.fileName)"
        label="已选文件"
      >
        <div class="file-info">
          <el-icon><Document /></el-icon>
          <span class="file-name" @click="handlePreviewFile" style="cursor: pointer">
            {{ materialForm.attach.originalName || materialForm.attach.fileName }}
          </span>
          <span class="file-size">({{ formatFileSize(materialForm.attach.fileSize) }})</span>
          <el-button
            type="primary"
            text
            icon="el-icon-download"
            @click="handleDownloadFile"
          >下载</el-button>
          <el-button
            type="danger"
            text
            icon="el-icon-delete"
            @click="handleRemoveFile"
          >删除</el-button>
        </div>
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="handleClose">取消</el-button>
      <el-button type="primary" @click="handleSubmit">确认添加</el-button>
    </template>
  </el-dialog>
</template>

<script>
import { uploadFile } from '@/api/affair/manage';
import { getToken } from '@/utils/auth';

export default {
  name: 'MaterialDialog',
  props: {
    modelValue: {
      type: Boolean,
      default: false,
    },
    title: {
      type: String,
      default: '添加材料',
    },
    materialData: {
      type: Object,
      default: () => ({
        id: null,
        materialName: '',
        materialType: '',
        materialCopies: 1,
        materialRemark: '',
        attachId: null,
        attach: null,
      }),
    },
  },
  emits: ['update:modelValue', 'submit'],
  data() {
    return {
      dialogVisible: false,
      materialForm: {
        id: null,
        materialName: '',
        materialType: '',
        materialCopies: 1,
        materialRemark: '',
        attachId: null,
        attach: null,
      },
      materialRules: {
        materialName: [
          {
            required: true,
            message: '请输入材料名称',
            trigger: 'blur',
          },
        ],
        materialType: [
          {
            required: true,
            message: '请选择材料类型',
            trigger: 'change',
          },
        ],
        materialCopies: [
          {
            required: true,
            message: '请输入份数要求',
            trigger: 'blur',
          },
        ],
        attachId: [
          {
            required: true,
            message: '请上传附件文件',
            trigger: 'change',
          },
        ],
      },
      materialTypeOptions: [],
      fileList: [],
      acceptFileTypes: '.pdf,.doc,.docx,.jpg,.jpeg,.png',
      uploadUrl: '/api/blade-resource/oss/endpoint/put-file-attach',
    };
  },
  computed: {
    uploadHeaders() {
      const token = getToken();
      return {
        'Blade-Auth': 'bearer ' + token,
        'Blade-Requested-With': 'BladeHttpRequest',
      };
    },
  },
  watch: {
    modelValue(val) {
      this.dialogVisible = val;
      if (val) {
        this.initForm();
        this.loadMaterialTypeDict();
      }
    },
    dialogVisible(val) {
      this.$emit('update:modelValue', val);
    },
  },
  methods: {
    initForm() {
      if (this.materialData && this.materialData.id) {
        // 编辑模式
        this.materialForm = JSON.parse(JSON.stringify(this.materialData));
        if (this.materialForm.attach) {
          // 确保 attach 对象有正确的字段
          if (!this.materialForm.attach.fileName && this.materialForm.attach.originalName) {
            this.materialForm.attach.fileName = this.materialForm.attach.originalName;
          }
          if (!this.materialForm.attach.filePath && this.materialForm.attach.link) {
            this.materialForm.attach.filePath = this.materialForm.attach.link;
          }
          this.fileList = [
            {
              name: this.materialForm.attach.originalName || '已上传文件',
              url: this.materialForm.attach.filePath || this.materialForm.attach.link,
              uid: this.materialForm.attach.id || -1,
            },
          ];
        }
      } else {
        // 新增模式
        this.materialForm = {
          id: null,
          materialName: '',
          materialType: '',
          materialCopies: 1,
          materialRemark: '',
          attachId: null,
          attach: null,
        };
        this.fileList = [];
      }
      this.$nextTick(() => {
        if (this.$refs.materialFormRef) {
          this.$refs.materialFormRef.clearValidate();
        }
      });
    },
    loadMaterialTypeDict() {
      // 加载材料类型字典
      this.$axios
        .get('/blade-system/dict/dictionary', {
          params: { code: 'material_type' },
        })
        .then((res) => {
          if (res.data && res.data.data) {
            this.materialTypeOptions = res.data.data;
          }
        })
        .catch(() => {
          // 使用默认选项
          this.materialTypeOptions = [
            { dictKey: '01', dictValue: '原件' },
            { dictKey: '02', dictValue: '复印件' },
            { dictKey: '03', dictValue: '电子版' },
            { dictKey: '04', dictValue: '其他' },
          ];
        });
    },
    beforeUpload(file) {
      const maxSize = 10 * 1024 * 1024; // 10MB
      const validTypes = [
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'image/jpeg',
        'image/png',
      ];

      if (file.size > maxSize) {
        this.$message.error('文件大小不能超过 10MB');
        return false;
      }

      if (!validTypes.includes(file.type)) {
        this.$message.error('文件格式不正确，仅支持 pdf/doc/docx/jpg/png');
        return false;
      }

      return true;
    },
    handleUploadSuccess(response, file, fileList) {
      console.log('上传响应:', response);
      if (response.success && response.data) {
        const attachData = response.data;
        this.materialForm.attachId = attachData.attachId;
        this.materialForm.attach = {
          id: attachData.attachId,
          fileName: attachData.name,
          originalName: attachData.originalName,
          filePath: attachData.link,
          fileSize: file.size,
        };
        this.fileList = fileList;
        this.$message.success('文件上传成功');
      } else {
        this.$message.error(response.msg || '文件上传失败');
      }
    },
    handleUploadError(error) {
      console.error('上传错误:', error);
      this.$message.error('文件上传失败');
    },
    handleRemoveFile() {
      this.$confirm('确定删除该附件？', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      })
        .then(() => {
          this.materialForm.attachId = null;
          this.materialForm.attach = null;
          this.fileList = [];
          if (this.$refs.uploadRef) {
            this.$refs.uploadRef.clearFiles();
          }
          this.$message.success('已删除附件');
        })
        .catch(() => {});
    },
    handlePreviewFile() {
      if (this.materialForm.attach && this.materialForm.attach.filePath) {
        const fileUrl = this.materialForm.attach.filePath;
        window.open(fileUrl, '_blank');
      }
    },
    handleDownloadFile() {
      if (this.materialForm.attach && this.materialForm.attach.filePath) {
        const link = document.createElement('a');
        link.href = this.materialForm.attach.filePath;
        link.download = this.materialForm.attach.originalName || 'download';
        link.target = '_blank';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }
    },
    handleSubmit() {
      this.$refs.materialFormRef.validate((valid) => {
        if (valid) {
          this.$emit('submit', { ...this.materialForm });
          this.dialogVisible = false;
        } else {
          return false;
        }
      });
    },
    handleClose() {
      this.$refs.materialFormRef?.resetFields();
      this.dialogVisible = false;
    },
    formatFileSize(bytes) {
      if (!bytes || bytes === 0) return '0 B';
      const k = 1024;
      const sizes = ['B', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    },
  },
};
</script>

<style scoped>
.material-upload {
  width: 100%;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.file-name {
  flex: 1;
  color: #606266;
  font-size: 14px;
}

.file-size {
  color: #909399;
  font-size: 12px;
}
</style>
